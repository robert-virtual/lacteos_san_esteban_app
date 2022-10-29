import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/compra.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';
import 'package:get/get.dart';

class ComprasForm extends StatelessWidget {
  ComprasForm({super.key});

  final formatDate = DateFormat("yyyy/MM/dd h:mm a");
  final productosStream = FirebaseFirestore.instance
      .collection("tipos_productos")
      .where("venta", isEqualTo: true)
      .withConverter<Producto>(
      fromFirestore: (snap, _) => Producto.fromJson(snap.data()!),
      toFirestore: (producto, _) => producto.toJson())
      .snapshots();
  final unidadesMedidaStream =
  FirebaseFirestore.instance.collection("unidades_medida").snapshots();
  final clientesStream = FirebaseFirestore.instance
      .collection("proveedores")
      .withConverter<Persona>(
      fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
      toFirestore: (proveedores, _) => proveedores.toJson())
      .snapshots();

  final empleadosRef = FirebaseFirestore.instance
      .collection("empleados")
      .withConverter<Persona>(
      fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
      toFirestore: (empleado, _) => empleado.toJson());
  final comprasRef = FirebaseFirestore.instance
      .collection("compras")
      .withConverter<Compra>(
      fromFirestore: (snap, _) => Compra.fromJson(snap.data()!),
      toFirestore: (compra, _) => compra.toJson());
  var detalles = List<DetalleVenta>.empty().obs;
  var cliente = Rx<DocumentReference<Persona>?>(null);
  final cantidad = TextEditingController();
  final precio = TextEditingController();
  var unidadMedida = Rx<String?>(null);
  var producto = Rx<DocumentReference<Producto>?>(null);

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text("Agregar Compras"),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Proveedor",
                        style: TextStyle(fontSize: 20),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed("/clientes_form");
                        },
                        child: Row(children: const [
                          Icon(Icons.add),
                          Text("Nuevo Proveedor")
                        ]),
                      ),
                    ],
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
                              () => DropdownButton<DocumentReference<Persona>>(
                            value: cliente.value,
                            onChanged: (text) {
                              if (text != null) {
                                cliente.value = text;
                              }
                            },
                            items: snap.data!.docs
                                .map(
                                  (e) => DropdownMenuItem(
                                value: e.reference,
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
                  buildAgregarProductoBottomSheet(context);
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
                        detalle.producto.id,
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
              if (cliente.value == null || detalles.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Guardar Venta"),
                      content: const Text(
                          "Debes seleccionar un proveedor y agregar productos a la venta "),
                      actions: [
                        TextButton(
                          child: const Text("Ok"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  },
                );
                return;
              }
              comprasRef
                  .add(
                Compra(
                  proveedor: cliente.value!,
                  empleado: empleadosRef
                      .doc(FirebaseAuth.instance.currentUser!.email),
                  fecha: Timestamp.now(),
                  detalles: detalles,
                ),
              )
                  .then((value) {
                const snackbar =
                SnackBar(content: Text("Venta guardada con exito"));
                ScaffoldMessenger.of(context).showSnackBar(snackbar);

                Navigator.of(context).pop();
              }).catchError(
                    (err) {
                  print(err);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Guardar Venta"),
                        content:
                        const Text("Hubo un error al guardar la venta"),
                        actions: [
                          TextButton(
                            child: const Text("Ok"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    },
                  );
                },
              );
            },
            label: const Text("Guardar"),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
    );
  }

  Future<dynamic> buildAgregarProductoBottomSheet(BuildContext context) {
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
                        () => DropdownButton<DocumentReference<Producto>>(
                      value: producto.value,
                      onChanged: (text) {
                        if (text != null) {
                          producto.value = text;
                        }
                      },
                      items: snap.data!.docs
                          .map(
                            (e) => DropdownMenuItem(
                          value: e.reference,
                          child: Text(e.data().producto),
                        ),
                      )
                          .toList(),
                    ),
                  );
                }),
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
                final e =
                snap.data!.docs.firstWhereOrNull((e) => e.id == "libras");
                if (e != null) {
                  unidadMedida.value = e.id;
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
            TextField(
              controller: precio,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                label: Text("Precio Total"),
              ),
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
                    if (unidadMedida.value == null ||
                        precio.text.trim().isEmpty ||
                        cantidad.text.trim().isEmpty ||
                        producto.value == null) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Agregar producto"),
                            content:
                            const Text("Debes ingresar todos los campos"),
                            actions: [
                              TextButton(
                                child: const Text("Ok"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        },
                      );
                      return;
                    }
                    detalles.add(
                      DetalleVenta(
                        unidadMedida: unidadMedida.value!,
                        precio: double.parse(precio.text),
                        cantidad: int.parse(cantidad.text),
                        producto: producto.value!,
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
