import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';

class EmpleadosForm extends StatelessWidget {
  EmpleadosForm({super.key});
  // cliente
  final nombre = TextEditingController();
  final correo = TextEditingController();
  final direccion = TextEditingController();
  final telefono = TextEditingController();
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final res = empleadosRef.doc(correo.text.trim());
          res
              .set(
            Persona(
              correo: correo.text,
              nombre: nombre.text,
              telefono: telefono.text,
              direccion: direccion.text,
              fechaRegistro: Timestamp.now(),
            ),
          )
              .then(
            (value) {
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
