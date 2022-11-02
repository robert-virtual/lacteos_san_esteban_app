import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';
import 'package:get/get.dart';

class ProveedoresPage extends StatelessWidget {
  ProveedoresPage({super.key});

  var searching = false.obs;
  final searchFocus = FocusNode();
  var proveedor = "".obs;
  final formatDate = DateFormat("yyyy/MM/dd h:mm a");
  final proveedoresCollection = FirebaseFirestore.instance
      .collection("proveedores")
      .withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (proveedor, _) => proveedor.toJson());
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
                        proveedor.value = value;
                      }
                      searching.value = false;
                    },
                  )
                : const Text("Proveedores");
          },
        ),
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
            if (proveedor.value.isNotEmpty) {
              return proveedoresCollection
                  .where("nombre", isGreaterThanOrEqualTo: proveedor.value)
                  .where("nombre",
                      isLessThanOrEqualTo: "${proveedor.value}\uf8ff")
                  .snapshots();
            }
            return proveedoresCollection.snapshots();
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
            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Visibility(
                        visible: proveedor.value.isNotEmpty,
                        child: TextButton(
                          onPressed: () {
                            proveedor.value = "";
                          },
                          child: const Text("Ver todos"),
                        ),
                      )
                    ],
                  ),
                ),
                SliverList(
                    delegate: SliverChildListDelegate(snap.data!.docs.map(
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
                            Text("Direccion: ${e.data().direccion.capitalize}"),
                            const SizedBox(
                              height: 10,
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "Ver compras a ${e.data().nombre.capitalize}",
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ).toList()))
              ],
            );
          })),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/proveedores_form");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
