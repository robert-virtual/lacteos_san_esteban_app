import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';
import 'package:get/get.dart';

class VentasForm extends StatelessWidget {
  VentasForm({super.key});

  final formatDate = DateFormat("yyyy/MM/dd h:mm a");
  final productosStream = FirebaseFirestore.instance
      .collection("tipos_productos")
      .withConverter<Producto>(
          fromFirestore: (snap, _) => Producto.fromJson(snap.data()!),
          toFirestore: (producto, _) => producto.toJson())
      .snapshots();
  final unidadesMedidaStream =
      FirebaseFirestore.instance.collection("unidades_medida").snapshots();
  final clientesStream = FirebaseFirestore.instance
      .collection("clientes")
      .withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (cliente, _) => cliente.toJson())
      .snapshots();

  final ventasRef = FirebaseFirestore.instance
      .collection("ventas")
      .withConverter<Venta>(
          fromFirestore: (snap, _) => Venta.fromJson(snap.data()!),
          toFirestore: (venta, _) => venta.toJson());
  var detalles = List<DetalleVenta>.empty().obs;
  var cliente = Rx<String?>(null);
  final cantidad = TextEditingController();
  final precio = TextEditingController();
  /* List<String> unidadesMedida = ["Libras", "Cajas", "Unidades"]; */
  var unidadMedida = Rx<String?>(null);
  var producto = Rx<String?>(null);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text("Agregar Ventas"),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 15.0),
                  child: Text(
                    "Cliente",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                StreamBuilder(
                    stream: clientesStream,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snap.hasError) {
                        return const Center(
                          child: Text("Ups ha habido un error"),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Obx(
                          () => DropdownButton<String>(
                            value: cliente.value,
                            onChanged: (text) {
                              if (text != null) {
                                cliente.value = text;
                              }
                            },
                            items: snap.data!.docs
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.id,
                                    child: Text(e.data().nombre),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      );
                    }),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                      "Empleado: ${FirebaseAuth.instance.currentUser!.email}"),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text("Fecha: ${formatDate.format(DateTime.now())} "),
                )
              ],
            ),
          ),
          SliverAppBar(
            primary: false,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Obx(
              () {
                final total = detalles.isNotEmpty
                    ? detalles.map((e) => e.precio).reduce((pv, cv) => pv + cv)
                    : 0;
                return Text("Productos, Total: $total");
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  buildShowModalBottomSheet(context);
                },
                child: Row(children: const [Icon(Icons.add), Text("Agregar")]),
              ),
            ],
          ),
          Obx(
            () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, idx) {
                  final detalle = detalles[idx];
                  return Dismissible(
                    background: Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text(
                            "Eliminar",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Eliminar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    key: ValueKey(detalle),
                    onDismissed: (direcction) {
                      detalles.removeAt(idx);
                    },
                    child: ListTile(
                      title: Text(
                        detalle.producto != null
                            ? detalle.producto!.producto
                            : "Producto sin Nombre",
                      ),
                      subtitle: Text(
                        "Cantidad: ${detalle.cantidad} ${detalle.unidadMedida}, Precio: ${detalle.precio}, Subtotal: ${detalle.precio * detalle.cantidad}",
                      ),
                    ),
                  );
                },
                childCount: detalles.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(width: 10.0),
          FloatingActionButton.extended(
            onPressed: () {
              /* ventasRef.add(Venta(cliente: , empleado: FirebaseAuth.instance.currentUser.email, fecha: fecha, detalles: detalles)) */
            },
            label: const Text("Guardar"),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
    );
  }

  Future<dynamic> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.only(
          top: 25,
          left: 15,
          right: 15,
          bottom: 25,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Agregar Producto",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "Producto",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
            StreamBuilder(
                stream: productosStream,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snap.hasError) {
                    return const Center(
                      child: Text("Ups ha habido un error"),
                    );
                  }
                  return Obx(
                    () => DropdownButton<String>(
                      value: producto.value,
                      onChanged: (text) {
                        if (text != null) {
                          producto.value = text;
                        }
                      },
                      items: snap.data!.docs
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.data().producto,
                              child: Text(e.data().producto),
                            ),
                          )
                          .toList(),
                    ),
                  );
                }),
            TextField(
              controller: precio,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                label: Text("Precio Total"),
              ),
            ),
            TextField(
              controller: cantidad,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                label: Text("Cantidad"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                "Unidad",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
            StreamBuilder(
              stream: unidadesMedidaStream,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snap.hasError) {
                  return const Center(
                    child: Text("Ups ha habido un error"),
                  );
                }
                return Obx(
                  () => DropdownButton<String>(
                    value: unidadMedida.value,
                    onChanged: (text) {
                      if (text != null) {
                        unidadMedida.value = text;
                      }
                    },
                    items: snap.data!.docs
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.id,
                            child: Text(e.data()["unidad"]),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancelar")),
                TextButton(
                  onPressed: () {
                    detalles.add(
                      DetalleVenta(
                        unidadMedida:
                            unidadMedida.value ?? "Sin unidad de medida",
                        precio: double.parse(precio.text),
                        cantidad: int.parse(cantidad.text),
                        producto: Producto(
                          producto: producto.value ?? "Producto sin nombre",
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Agregar"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
