import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/compra.dart';
import 'package:get/get.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';

class ComprasPage extends StatelessWidget {
  ComprasPage({super.key, this.proveedor, this.empleado});
  DocumentReference<Persona>? proveedor;
  DocumentReference<Persona>? empleado;
  var rxEmpleado = Rx<DocumentReference<Persona>?>(null);
  var rxProveedor = Rx<DocumentReference<Persona>?>(null);
  var rxFechaInicial = Rx<Timestamp?>(null);
  var rxFechaFinal = Rx<Timestamp?>(null);
  final formatDateTime = DateFormat("dd MMM yyyy h:mm a");
  final formatDate = DateFormat("dd/MM/yyyy");
  final comprasCollection =
      FirebaseFirestore.instance.collection("compras").withConverter<Compra>(
            fromFirestore: (snap, _) => Compra.fromJson(snap.data()!),
            toFirestore: (compra, _) => compra.toJson(),
          );

  @override
  Widget build(BuildContext context) {
    if (empleado != null) {
      rxEmpleado.value = empleado;
    }
    if (proveedor != null) {
      rxProveedor.value = proveedor;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compras"),
      ),
      body: Obx(() => StreamBuilder(
            stream: () {
              return comprasCollection
                  .where("proveedor", isEqualTo: proveedor)
                  .where("fecha", isLessThanOrEqualTo: rxFechaInicial.value)
                  .where("fecha", isGreaterThanOrEqualTo: rxFechaFinal.value)
                  .orderBy("fecha", descending: true)
                  .snapshots();
            }(),
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
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
                    title: Text("${snap.data!.docs.length} Resultados"),
                    actions: [
                      ChoiceChip(
                        label: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Fecha"),
                            Icon(
                              rxFechaInicial.value != null
                                  ? Icons.close
                                  : Icons.expand_more,
                            )
                          ],
                        ),
                        selected: rxFechaFinal.value != null ||
                            rxFechaInicial.value != null,
                        onSelected: (value) {
                          if (!value) {
                            rxFechaFinal.value = null;
                            rxFechaInicial.value = null;
                            return;
                          }
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Fecha",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Aplicar"),
                                      )
                                    ],
                                  ),
                                  Text("Fecha inicial",
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor)),
                                  OutlinedButton(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Obx(() => Text(
                                              rxFechaInicial.value != null
                                                  ? formatDateTime.format(
                                                      rxFechaInicial.value!
                                                          .toDate())
                                                  : "Seleccionar fecha")),
                                          const Icon(Icons.date_range)
                                        ]),
                                    onPressed: () async {
                                      final fechaInical = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2021),
                                        lastDate: DateTime.now(),
                                      );
                                      if (fechaInical != null) {
                                        rxFechaInicial.value =
                                            Timestamp.fromDate(
                                          fechaInical.add(
                                            const Duration(days: 1),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Text("Fecha final",
                                      style: TextStyle(
                                          color: Theme.of(context).hintColor)),
                                  OutlinedButton(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Obx(() => Text(rxFechaFinal.value !=
                                                null
                                            ? formatDateTime.format(
                                                rxFechaFinal.value!.toDate())
                                            : "Seleccionar fecha")),
                                        const Icon(Icons.date_range)
                                      ],
                                    ),
                                    onPressed: () async {
                                      final fechaFinal = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2021),
                                        lastDate: DateTime.now(),
                                      );
                                      if (fechaFinal != null) {
                                        rxFechaFinal.value = Timestamp.fromDate(
                                          fechaFinal,
                                        );
                                      }
                                    },
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
                      items.addAll(
                        [
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
                          Chip(
                            label: Text(
                              formatDateTime.format(
                                e.data().fecha.toDate(),
                              ),
                            ),
                          ),
                        ],
                      );
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
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/compras_form");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
