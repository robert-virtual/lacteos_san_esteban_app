import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';
import 'package:get/get.dart';

class EmpleadosForm extends StatelessWidget {
  EmpleadosForm({super.key});

  final bitacoraRef = FirebaseFirestore.instance.collection("bitacora");
  // cliente
  final nombre = TextEditingController();
  final correo = TextEditingController();
  final direccion = TextEditingController();
  final telefono = TextEditingController();
  final clave = TextEditingController();
  var admin = false.obs;
  var visiblePass = false.obs;
  var passwordsMatch = true.obs;
  var validEmail = true.obs;
  var emptyPass = false.obs;
  final confirmarClave = TextEditingController();
  // cliente

  final empleadosRef =
      FirebaseFirestore.instance.collection("empleados").withConverter<Persona>(
            fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
            toFirestore: (empleado, _) => empleado.toJson(),
          );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Empleado")),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          TextField(
            controller: nombre,
            decoration: const InputDecoration(
              label: Text("Nombre"),
            ),
          ),
          Obx(
            () => TextField(
              controller: correo,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => validEmail.value = value.isEmail,
              decoration: InputDecoration(
                label: const Text("Correo"),
                errorText: !validEmail.value ? "Correo no valido" : null,
              ),
            ),
          ),
          TextField(
            controller: direccion,
            decoration: const InputDecoration(
              label: Text("Direccion"),
            ),
          ),
          TextField(
            controller: telefono,
            keyboardType: TextInputType.number,
            maxLength: 8,
            decoration: const InputDecoration(
              label: Text("Telefono"),
              counterText: "",
            ),
          ),
          Obx(
            () => TextField(
              controller: clave,
              obscureText: !visiblePass.value,
              onChanged: (value) => emptyPass.value = clave.text.trim().isEmpty,
              decoration: InputDecoration(
                label: const Text("Clave"),
                errorText: emptyPass.value ? "Campo requerido" : null,
              ),
            ),
          ),
          Obx(
            () => TextField(
              controller: confirmarClave,
              obscureText: !visiblePass.value,
              onChanged: (value) => passwordsMatch.value = value == clave.text,
              decoration: InputDecoration(
                label: const Text("Confirmar Clave"),
                errorText: !passwordsMatch.value ? "Claves no coinciden" : null,
              ),
            ),
          ),
          Row(children: [
            Obx(
              () => Checkbox(
                value: visiblePass.value,
                onChanged: changeVisiblePass,
              ),
            ),
            TextButton(
              onPressed: changeVisiblePass,
              child: Text(
                "Mostrar clave",
                style: TextStyle(
                    fontSize: 17.0,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.normal),
              ),
            ),
          ]),
          Row(children: [
            Obx(
              () => Checkbox(
                value: admin.value,
                onChanged: toogleAdmin,
              ),
            ),
            TextButton(
              onPressed: toogleAdmin,
              child: Text(
                "Administrador",
                style: TextStyle(
                  fontSize: 17.0,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ]),
          Text(
            "Este empleado podra crear mas cuentas para empleados",
            style: TextStyle(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            if (!(await isAdmin())) {
              const snackBar = SnackBar(
                content: Text(
                    "No tiene los permisos necesarios para agregar nuevos empleados"),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }

            if (checkInputs()) {
              return;
            }
            final credentials =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: correo.text,
              password: clave.text,
            );
            await credentials.user?.updateDisplayName(nombre.text);
            final res = empleadosRef.doc(correo.text.trim());
            final empleado = Persona(
              admin: admin.value,
              correo: correo.text,
              nombre: nombre.text.trim().toLowerCase(),
              telefono: telefono.text,
              direccion: direccion.text,
              fechaRegistro: Timestamp.now(),
            );
            await res.set(
              empleado,
            );

            bitacoraRef.add(
              {
                "correoEmpleado": FirebaseAuth.instance.currentUser!.email,
                "nombreEmpleado":
                    FirebaseAuth.instance.currentUser!.displayName,
                "empleadoRef":
                    empleadosRef.doc(FirebaseAuth.instance.currentUser!.email),
                "fecha": Timestamp.now(),
                "accion": "Insertar empleado",
                "datos": empleado.toJson()
              },
            );
            Navigator.pop(context, res);
          } catch (e) {
            final snackBar = SnackBar(
              content: Text(e.toString()),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        icon: const Icon(Icons.save),
        label: const Text("Guardar"),
      ),
    );
  }

  void toogleAdmin([bool? value]) => admin.value = value ?? !admin.value;

  void changeVisiblePass([bool? value]) =>
      visiblePass.value = value ?? !visiblePass.value;

  Future<bool> isAdmin() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final empleado = await empleadosRef.doc(currentUser.email).get();
    if (!empleado.exists) return false;
    print("empleado exists");
    final data = empleado.data();
    if (data == null) return false;
    return data.admin!;
  }

  bool checkInputs() {
    passwordsMatch.value = clave.text == confirmarClave.text;
    validEmail.value = correo.text.isEmail;
    emptyPass.value = clave.text.isEmpty;
    return !passwordsMatch.value || !validEmail.value || emptyPass.value;
  }
}
