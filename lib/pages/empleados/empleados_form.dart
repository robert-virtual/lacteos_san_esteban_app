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
          TextField(
            controller: correo,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              label: Text("Correo"),
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
              decoration: const InputDecoration(
                label: Text("Clave"),
              ),
            ),
          ),
          Obx(
            () => TextField(
              controller: confirmarClave,
              obscureText: !visiblePass.value,
              decoration: const InputDecoration(
                label: Text("Confirmar Clave"),
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
          final res = empleadosRef.doc(correo.text.trim());
          final empleado = Persona(
            admin: admin.value,
            correo: correo.text,
            nombre: nombre.text,
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
              "nombreEmpleado": FirebaseAuth.instance.currentUser!.displayName,
              "empleadoRef":
                  empleadosRef.doc(FirebaseAuth.instance.currentUser!.email),
              "fecha": Timestamp.now(),
              "accion": "Insertar empleado",
              "datos": empleado.toJson()
            },
          );
          FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: correo.text,
            password: clave.text,
          );
          Navigator.pop(context, res);
        },
        icon: const Icon(Icons.save),
        label: const Text("Guardar"),
      ),
    );
  }

  void toogleAdmin([bool? value]) => admin.value = value ?? !admin.value;

  void changeVisiblePass([bool? value]) =>
      visiblePass.value = value ?? !visiblePass.value;
}
