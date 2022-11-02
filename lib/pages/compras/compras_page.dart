import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/compra.dart';
import 'package:get/get.dart';

class ComprasPage extends StatelessWidget {
  ComprasPage({super.key, this.proveedor});
  String? proveedor;
  var rxFecha = Rx<Timestamp?>(null);
  final formatDate = DateFormat("yyyy/MM/dd h:mm a");

  @override
  Widget build(BuildContext context) {
    final comprasStream = FirebaseFirestore.instance
        .collection("compras")
        .where("proveedor", isEqualTo: proveedor)
        .withConverter<Compra>(
          fromFirestore: (snap, _) => Compra.fromJson(snap.data()!),
          toFirestore: (compra, _) => compra.toJson(),
        )
        .snapshots();
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
          /*
ChoiceChip(
                              label: Row(
                                children: [
                                  Text("Fecha"),
                                  Icon(
                                   fecha.value.isNotEmpty 
                                        ? Icons.close
                                        : Icons.expand_more,
                                  ),
                                ],
                              ),
                              selected: appliedFilters.contains(e),
                              onSelected: (value) {
                                
                              },
                            )
*/
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                actions: [
                  ChoiceChip(
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Fecha"),
                        Icon(
                          rxFecha.value != null
                              ? Icons.close
                              : Icons.expand_more,
                        )
                      ],
                    ),
                    selected: false,
                    onSelected: (value) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Fecha"),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text("Aplicar"),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
                pinned: true,
              ),
              SliverList(
                  delegate: SliverChildListDelegate(snap.data!.docs.map(
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
                    Text("Proveedor: ${e.data().proveedor.id}"),
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
              ).toList()))
            ],
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
