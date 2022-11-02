import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/produccion.dart';
import 'package:get/get.dart';

class ProduccionPage extends StatelessWidget {
  ProduccionPage({super.key});

  final filters = [
    "Fecha",
  ];
  var appliedFilters = <String>[].obs;
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Wrap(
                    spacing: 4.0,
                    children: filters
                        .map(
                          (e) => Obx(
                            () => ChoiceChip(
                              label: Row(
                                children: [
                                  Text(e),
                                  Icon(
                                    appliedFilters.contains(e)
                                        ? Icons.close
                                        : Icons.expand_more,
                                  ),
                                ],
                              ),
                              selected: appliedFilters.contains(e),
                              onSelected: (value) {
                                print(value);
                                if (value) {
                                  appliedFilters.add(e);
                                  switch (e) {
                                    case "Proveedor":
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) => Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text("Cliente"),
                                                  TextButton(
                                                    onPressed: () {},
                                                    child:
                                                        const Text("Aplicar"),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                      break;
                                    case "Empleado":
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) => Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text("Empleado"),
                                                  TextButton(
                                                    onPressed: () {},
                                                    child:
                                                        const Text("Aplicar"),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                      break;
                                    case "Fecha":
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) => Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text("Fecha"),
                                                  TextButton(
                                                    onPressed: () {},
                                                    child:
                                                        const Text("Aplicar"),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                      break;
                                    default:
                                  }
                                  print(appliedFilters);
                                  return;
                                }
                                appliedFilters.remove(e);
                                print(appliedFilters);
                                /* Navigator.of(context).popAndPushNamed("/home"); */
                              },
                            ),
                          ),
                        )
                        .toList(),
                  )
                ],
              ),
            ),
          )),
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
