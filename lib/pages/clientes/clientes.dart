import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';
import 'package:lacteos_san_esteban_app/pages/home_page.dart';
import 'package:get/get.dart';

class ClientesPage extends StatelessWidget {
  ClientesPage({super.key});
  var searching = false.obs;
  final searchFocus = FocusNode();
  var cliente = "".obs;
  final formatDate = DateFormat("yyyy/MM/dd h:mm a");
  final clientesCollection =
      FirebaseFirestore.instance.collection("clientes").withConverter<Persona>(
            fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
            toFirestore: (cliente, _) => cliente.toJson(),
          );
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
        title: Obx(() {
          return searching.value
              ? TextField(
                  focusNode: searchFocus,
                  decoration: const InputDecoration(hintText: "Buscar..."),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      cliente.value = value;
                    }
                    searching.value = false;
                  },
                )
              : const Text("Clientes");
        }),
        actions: [
          IconButton(
            onPressed: () {
              searching.value = true;
              searchFocus.requestFocus();
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: Obx(() => StreamBuilder(stream: () {
            if (cliente.value.isNotEmpty) {
              return clientesCollection
                  .where("nombre", isGreaterThanOrEqualTo: cliente.value)
                  .where("nombre",
                      isLessThanOrEqualTo: "${cliente.value}\uf8ff")
                  .snapshots();
            }
            return clientesCollection.snapshots();
          }(), builder: (context, snap) {
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
            if (snap.data!.docs.isEmpty && cliente.value.isNotEmpty) {
              return Center(
                child: Text(
                    "No se encontraron clientes con el nombre \"${cliente.value}\""),
              );
            }
            return CustomScrollView(
              slivers: [
                SliverList(
                    delegate: SliverChildListDelegate([
                  Visibility(
                    visible: cliente.value.isNotEmpty,
                    child: TextButton(
                      onPressed: () {
                        cliente.value = "";
                      },
                      child: const Text("Ver todos"),
                    ),
                  )
                ])),
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
                                Text("Correo: ${e.data().correo}"),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    "Telefono: ${e.data().telefono.capitalize}"),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    "Direccion: ${e.data().direccion.capitalize}"),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).popAndPushNamed(
                                      "/home",
                                      arguments:
                                          HomePageArgs(cliente: e.reference),
                                    );
                                  },
                                  child: Text(
                                      "Ventas a ${e.data().nombre.capitalize}"),
                                )
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
          })),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/clientes_form");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
