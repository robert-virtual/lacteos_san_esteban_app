import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';
import 'package:get/get.dart';

class ClientesForm extends StatelessWidget {
  ClientesForm({super.key});
  var saving = false.obs;
  final empleadosRef = FirebaseFirestore.instance
      .collection("empleados")
      .withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (empleado, _) => empleado.toJson());
  final bitacoraRef = FirebaseFirestore.instance.collection("bitacora");
  // cliente
  final nombre = TextEditingController();
  final correo = TextEditingController();
  final direccion = TextEditingController();
  final telefono = TextEditingController();
  // cliente

  final clientesRef = FirebaseFirestore.instance
      .collection("clientes")
      .withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (cliente, _) => cliente.toJson());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo Cliente"),
      ),
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
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: () {
            if (saving.value) {
              return;
            }
            saving.value = true;
            final res = clientesRef.doc(correo.text.trim());
            final cliente = Persona(
              correo: correo.text.trim(),
              nombre: nombre.text.trim().toLowerCase(),
              telefono: telefono.text.trim(),
              direccion: direccion.text.trim().toLowerCase(),
              fechaRegistro: Timestamp.now(),
            );
            res
                .set(
              cliente,
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
                    "accion": "Insertar cliente",
                    "datos": cliente.toJson()
                  },
                );
                saving.value = true;
                Navigator.pop(context, res);
              },
            );
          },
          icon: const Icon(Icons.save),
          label: Text(saving.value ? "Guardando..." : "Guardar"),
        ),
      ),
    );
  }
}
