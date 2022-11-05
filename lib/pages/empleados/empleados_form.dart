import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';

class EmpleadosForm extends StatelessWidget {
  EmpleadosForm({super.key});

  final bitacoraRef = FirebaseFirestore.instance.collection("bitacora");
  // cliente
  final nombre = TextEditingController();
  final correo = TextEditingController();
  final direccion = TextEditingController();
  final telefono = TextEditingController();
  final clave = TextEditingController();
  final confirmarClave = TextEditingController();
  // cliente

  final empleadosRef = FirebaseFirestore.instance
      .collection("empleados")
      .withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (empleado, _) => empleado.toJson());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Empleado")),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 25,
          left: 15,
          right: 15,
          bottom: 25,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              ),
            ),
            TextField(
              controller: clave,
              obscureText: true,
              decoration: InputDecoration(
                suffix: IconButton(
                    onPressed: () {}, icon: const Icon(Icons.password)),
                label: const Text("Clave"),
              ),
            ),
            TextField(
              controller: confirmarClave,
              obscureText: true,
              decoration: InputDecoration(
                suffix: IconButton(
                    onPressed: () {}, icon: const Icon(Icons.password)),
                label: const Text("Confirmar Clave"),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final res = empleadosRef.doc(correo.text.trim());
          final empleado = Persona(
            correo: correo.text,
            nombre: nombre.text,
            telefono: telefono.text,
            direccion: direccion.text,
            fechaRegistro: Timestamp.now(),
          );
          res
              .set(
            empleado,
          )
              .then(
            (value) {
              bitacoraRef.add(
                {
                  "correoEmpleado": FirebaseAuth.instance.currentUser!.email,
                  "nombreEmpleado":
                      FirebaseAuth.instance.currentUser!.displayName,
                  "empleadoRef": empleadosRef
                      .doc(FirebaseAuth.instance.currentUser!.email),
                  "fecha": Timestamp.now(),
                  "accion": "Insertar empleado",
                  "datos": empleado.toJson()
                },
              );
              Navigator.pop(context, res);
            },
          );
        },
        icon: const Icon(Icons.save),
        label: const Text("Guardar"),
      ),
    );
  }
}
