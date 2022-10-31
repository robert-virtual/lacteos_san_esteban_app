import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';

class VentasPage extends StatelessWidget {
  VentasPage({super.key});

  final formatDate = DateFormat("yyyy/MM/dd h:mm a");
  final ventasStream = FirebaseFirestore.instance
      .collection("ventas")
      .withConverter<Venta>(
          fromFirestore: (snap, _) => Venta.fromJson(snap.data()!),
          toFirestore: (venta, _) => venta.toJson())
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ventas"),
      ),
      body: StreamBuilder(
          stream: ventasStream,
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
                    const Text(
                      "Productos:",
                      style: boldtext,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                  ];
                  double total = 0;
                  items.addAll(
                    e.data().detalles.map(
                      (d) {
                        total += d.precio;
                        return Text(
                            "${d.cantidad} ${d.unidadMedida} ${d.producto.id} L.${d.precio}");
                      },
                    ),
                  );
                  items.addAll([
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "Total: $total",
                      style: boldtext,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text("Cliente: ${e.data().cliente.id}"),
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
          Navigator.of(context).pushNamed("/ventas_form");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
