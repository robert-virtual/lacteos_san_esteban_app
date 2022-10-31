import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/compra.dart';

class ComprasPage extends StatelessWidget {
  ComprasPage({super.key});
  final formatDate = DateFormat("yyyy/MM/dd h:mm a");
  final comprasStream = FirebaseFirestore.instance
      .collection("compras")
      .withConverter<Compra>(
        fromFirestore: (snap, _) => Compra.fromJson(snap.data()!),
        toFirestore: (compra, _) => compra.toJson(),
      )
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compras"),
      ),
      body: StreamBuilder(
        stream: comprasStream,
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
            children: snap.data!.docs
                .map(
                  (e) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("Proveedor: ${e.data().proveedor.id}"),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text("Empleado: ${e.data().empleado.id}"),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(formatDate.format(e.data().fecha.toDate())),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/compras_form");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
