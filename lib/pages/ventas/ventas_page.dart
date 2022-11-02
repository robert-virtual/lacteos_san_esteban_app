import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';
import 'package:get/get.dart';

class Filtro {
  String name;
  dynamic value;
  Filtro({this.value, required this.name});
}

class VentasPage extends StatelessWidget {
  VentasPage({super.key, this.cliente, this.empleado});
  DocumentReference<Persona>? cliente;
  DocumentReference<Persona>? empleado;
  var rxEmpleado = Rx<DocumentReference<Persona>?>(null);
  var rxCliente = Rx<DocumentReference<Persona>?>(null);
  var rxFecha = Rx<Timestamp?>(null);
  final formatDate = DateFormat("yyyy/MM/dd h:mm a");
  final filters = ["Cliente", "Empleado", "Fecha"];
  var appliedFilters = <String>[].obs;
  final ventasCollection = FirebaseFirestore.instance.collection("ventas");
  @override
  Widget build(BuildContext context) {
    if (empleado != null) {
      /* Filtro<DocumentReference<Persona>>(name: "cliente", value: cliente); */
      appliedFilters.add("Empleado");
      rxEmpleado.value = empleado;
    }
    if (cliente != null) {
      /* Filtro<DocumentReference<Persona>>(name: "cliente", value: cliente); */
      appliedFilters.add("Cliente");
      rxCliente.value = cliente;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ventas"),
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
                                  case "Cliente":
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
                                                  child: const Text("Aplicar"),
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
                                                  child: const Text("Aplicar"),
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
                                                  child: const Text("Aplicar"),
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
        ),
      ),
      body: Obx(() => StreamBuilder(
          stream: ventasCollection
              .where("cliente", isEqualTo: rxCliente.value)
              .where("empleado", isEqualTo: rxEmpleado.value)
              .where("fecha", isEqualTo: rxFecha.value)
              .withConverter<Venta>(
                  fromFirestore: (snap, _) => Venta.fromJson(snap.data()!),
                  toFirestore: (venta, _) => venta.toJson())
              .snapshots(),
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
          })),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/ventas_form");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
