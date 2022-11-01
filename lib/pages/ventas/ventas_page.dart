import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';
import 'package:get/get.dart';

class Filtro<T> {
  String name;
  T? value;
  Filtro({this.value, required this.name});
}

class VentasPage extends StatelessWidget {
  VentasPage({super.key, this.cliente});
  DocumentReference<Persona>? cliente;
  final formatDate = DateFormat("yyyy/MM/dd h:mm a");
  var filtros = <Filtro<DocumentReference<Persona>>>[].obs;
  @override
  Widget build(BuildContext context) {
    final ventasStream = FirebaseFirestore.instance
        .collection("ventas")
        .where("cliente", isEqualTo: cliente)
        .withConverter<Venta>(
            fromFirestore: (snap, _) => Venta.fromJson(snap.data()!),
            toFirestore: (venta, _) => venta.toJson())
        .snapshots();
    if (cliente != null) {
      filtros.add(
          Filtro<DocumentReference<Persona>>(name: "cliente", value: cliente));
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          Obx(
            () => SliverAppBar(
              title: const Text("Ventas"),
              bottom: filtros.isNotEmpty
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(50),
                      child: SingleChildScrollView(
                        child: Row(
                          children: filtros
                              .map(
                                (e) => ChoiceChip(
                                  label: Row(children: [
                                    Text("${e.name}: ${e.value?.id}"),
                                    const Icon(Icons.close),
                                  ]),
                                  selected: false,
                                  onSelected: (value) {
                                    filtros.remove(e);
                                    Navigator.of(context)
                                        .popAndPushNamed("/home");
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          StreamBuilder(
              stream: ventasStream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return SliverList(
                      delegate: SliverChildListDelegate([
                    const Center(
                      child: Text("Ups ha ocurrido un error"),
                    )
                  ]));
                }
                if (snap.connectionState == ConnectionState.waiting) {
                  return SliverList(
                      delegate: SliverChildListDelegate([
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  ]));
                }
                return SliverList(
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
                  ).toList()),
                );
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/ventas_form");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
