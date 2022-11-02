import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';
import 'package:get/get.dart';

class EmpleadosPage extends StatelessWidget {
  EmpleadosPage({super.key});

  var searching = false.obs;
  final searchFocus = FocusNode();
  var empleado = "".obs;
  final formatDate = DateFormat("yyyy/MM/dd h:mm a");
  final empleadosCollection = FirebaseFirestore.instance
      .collection("empleados")
      .withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (empleado, _) => empleado.toJson());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Obx(
          () => Visibility(
            visible: searching.value,
            child: IconButton(
              onPressed: () => searching.value = false,
              icon: const Icon(Icons.arrow_back),
            ),
          ),
        ),
        title: Obx(
          () {
            return searching.value
                ? TextField(
                    focusNode: searchFocus,
                    decoration: const InputDecoration(hintText: "Buscar..."),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        empleado.value = value;
                      }
                      searching.value = false;
                    },
                  )
                : const Text("Empleados");
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/cuenta");
            },
            icon: const Icon(Icons.account_box),
          ),
          IconButton(
            onPressed: () {
              searching.value = true;
              searchFocus.requestFocus();
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: Obx(
        () => StreamBuilder(
          stream: () {
            if (empleado.value.isNotEmpty) {
              return empleadosCollection
                  .where("nombre", isGreaterThanOrEqualTo: empleado.value)
                  .where("nombre",
                      isLessThanOrEqualTo: "${empleado.value}\uf8ff")
                  .snapshots();
            }
            return empleadosCollection.snapshots();
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
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Visibility(
                        visible: empleado.value.isNotEmpty,
                        child: TextButton(
                          onPressed: () {
                            empleado.value = "";
                          },
                          child: const Text("Ver todos"),
                        ),
                      )
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    snap.data!.docs.map(
                      (e) {
                        const boldtext = TextStyle(fontWeight: FontWeight.bold);
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.data().nombre.capitalize ?? e.data().nombre,
                                  style: boldtext,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("Correo: ${e.data().correo}"),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("Telefono: ${e.data().telefono}"),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    "Direccion: ${e.data().direccion.capitalize}"),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(children: [
                                  Wrap(
                                    spacing: 4.0,
                                    children: [
                                      ChoiceChip(
                                        selected: false,
                                        onSelected: (value) {},
                                        label: const Text(
                                          "Ventas",
                                        ),
                                      ),
                                      ChoiceChip(
                                        selected: false,
                                        onSelected: (value) {},
                                        label: const Text(
                                          "Compras",
                                        ),
                                      ),
                                      ChoiceChip(
                                        selected: false,
                                        onSelected: (value) {},
                                        label: const Text(
                                          "Produccion",
                                        ),
                                      )
                                    ],
                                  )
                                ]),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                )
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/empleados_form");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
