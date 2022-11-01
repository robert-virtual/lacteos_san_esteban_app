import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';
import 'package:lacteos_san_esteban_app/pages/home_page.dart';

class ClientesPage extends StatelessWidget {
  ClientesPage({super.key});

  final formatDate = DateFormat("yyyy/MM/dd h:mm a");
  final clientesStream = FirebaseFirestore.instance
      .collection("clientes")
      .withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (cliente, _) => cliente.toJson())
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clientes"),
      ),
      body: StreamBuilder(
          stream: clientesStream,
          builder: (context, snap) {
            if (snap.hasError) {
              return const Center(
                child: Text("Ups ha ocurrido un error"),
              );
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(10.0),
              children: snap.data!.docs.map(
                (e) {
                  const boldtext = TextStyle(fontWeight: FontWeight.bold);
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.data().nombre,
                            style: boldtext,
                          ),
                          Text("Correo: ${e.data().correo}"),
                          const SizedBox(
                            height: 10,
                          ),
                          Text("Telefono: ${e.data().telefono}"),
                          const SizedBox(
                            height: 10,
                          ),
                          Text("Direccion: ${e.data().direccion}"),
                          const SizedBox(
                            height: 10,
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).popAndPushNamed(
                                  "/home",
                                  arguments: HomePageArgs(cliente: e.reference),
                                );
                              },
                              child: Text("Ver ventas a ${e.data().nombre}"))
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/clientes_form");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
