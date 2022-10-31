import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/produccion.dart';

class ProduccionPage extends StatelessWidget {
  ProduccionPage({super.key});

  final formatDate = DateFormat("yyyy/MM/dd h:mm a");
  final produccionStream = FirebaseFirestore.instance
      .collection("produccion")
      .withConverter<Produccion>(
          fromFirestore: (snap, _) => Produccion.fromJson(snap.data()!),
          toFirestore: (produccion, _) => produccion.toJson())
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produccion"),
      ),
      body: StreamBuilder(
          stream: produccionStream,
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
                  final items = <Widget>[
                    Text(
                      "${e.data().cantidadProducida} de ${e.data().producto.id}",
                      style: boldtext,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      "Insumos:",
                      style: boldtext,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                  ];
                  items.addAll(
                    e.data().insumos.map(
                      (d) {
                        return Text("${d.cantidad} ${d.producto}");
                      },
                    ),
                  );
                  items.addAll([
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "Empleado: ${e.data().empleado.id}",
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(formatDate.format(e.data().fecha.toDate())),
                  ]);
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: items,
                      ),
                    ),
                  );
                },
              ).toList(),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/produccion_form");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
