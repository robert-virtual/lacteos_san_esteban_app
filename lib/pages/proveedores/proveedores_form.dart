import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';

class ProveedoresForm extends StatelessWidget {
  ProveedoresForm({super.key});
  final bitacoraRef = FirebaseFirestore.instance.collection("bitacora");
  final empleadosRef = FirebaseFirestore.instance
      .collection("empleados")
      .withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (empleado, _) => empleado.toJson());
  // cliente
  final nombre = TextEditingController();
  final correo = TextEditingController();
  final direccion = TextEditingController();
  final telefono = TextEditingController();
  // cliente

  final proveedoresRef = FirebaseFirestore.instance
      .collection("proveedores")
      .withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (proveedor, _) => proveedor.toJson());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Proveedor")),
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
          final res = proveedoresRef.doc(correo.text.trim());
          final proveedor = Persona(
            correo: correo.text,
            nombre: nombre.text,
            telefono: telefono.text,
            direccion: direccion.text,
            fechaRegistro: Timestamp.now(),
          );
          res
              .set(
            proveedor,
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
                  "accion": "Insertar proveedor",
                  "datos": proveedor.toJson()
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
