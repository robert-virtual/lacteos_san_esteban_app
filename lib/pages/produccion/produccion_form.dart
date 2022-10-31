import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/produccion.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';

class ProduccionForm extends StatelessWidget {
  ProduccionForm({super.key});

  final formatDate = DateFormat("yyyy/MM/dd h:mm a");
  var productos = <QueryDocumentSnapshot<Producto>>[].obs;
  final productosInsumoStream = FirebaseFirestore.instance
      .collection("tipos_productos")
      .where("insumo", isEqualTo: true)
      .withConverter<Producto>(
          fromFirestore: (snap, _) => Producto.fromJson(snap.data()!),
          toFirestore: (producto, _) => producto.toJson())
      .snapshots();
  final productosStream = FirebaseFirestore.instance
      .collection("tipos_productos")
      .where("venta", isEqualTo: true)
      .withConverter<Producto>(
          fromFirestore: (snap, _) => Producto.fromJson(snap.data()!),
          toFirestore: (producto, _) => producto.toJson())
      .snapshots();
  final unidadesMedidaStream =
      FirebaseFirestore.instance.collection("unidades_medida").snapshots();

  final empleadosRef = FirebaseFirestore.instance
      .collection("empleados")
      .withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (empleado, _) => empleado.toJson());
  final produccionRef = FirebaseFirestore.instance
      .collection("produccion")
      .withConverter<Produccion>(
          fromFirestore: (snap, _) => Produccion.fromJson(snap.data()!),
          toFirestore: (produccion, _) => produccion.toJson());
  var insumos = List<DetalleInsumo>.empty().obs;
  final cantidadProducida = TextEditingController();
  final cantidad = TextEditingController();
  final precio = TextEditingController();
  var unidadMedida = Rx<String?>(null);
  var unidadMedidaProducto = Rx<String?>(null);
  var producto = Rx<DocumentReference<Producto>?>(null);
  var productoInsumo = Rx<DocumentReference<Producto>?>(null);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text("Formulario de produccion"),
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
                        "Producto",
                        style: TextStyle(fontSize: 20),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed("/productos_form");
                        },
                        child: Row(children: const [
                          Icon(Icons.add),
                          Text("Nuevo Producto")
                        ]),
                      ),
                    ],
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
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Obx(
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
                                  child: Text(
                                    e.data().producto,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: cantidadProducida,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text("Libras Producidas"),
                    ),
                  ),
                ),
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
            title: Obx(() => Text("Insumos: ${insumos.length}")),
            actions: [
              TextButton(
                onPressed: () {
                  buildAgregarProductoBottomSheet(context);
                },
                child: Row(
                    children: const [Icon(Icons.add), Text("Agregar Insumo")]),
              ),
            ],
          ),
          Obx(
            () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, idx) {
                  final insumo = insumos[idx];
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
                    key: ValueKey(insumo),
                    onDismissed: (direcction) {
                      insumos.removeAt(idx);
                    },
                    child: ListTile(
                      title: Text(
                        insumo.producto,
                      ),
                      subtitle: Text(
                        "Cantidad: ${insumo.cantidad} , Subtotal: ${insumo.cantidad}",
                      ),
                    ),
                  );
                },
                childCount: insumos.length,
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
              if (producto.value == null || insumos.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Guardar"),
                      content: const Text(
                          "Debes seleccionar un producto y agregar insumos"),
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
              produccionRef
                  .add(
                Produccion(
                  cantidadProducida:
                      "${cantidad.text} ${productoInsumo.value != null ? productos.firstWhere(
                            (p0) => p0.reference == productoInsumo.value,
                          ).data().unidad : ""}",
                  empleado: empleadosRef
                      .doc(FirebaseAuth.instance.currentUser!.email),
                  fecha: Timestamp.now(),
                  insumos: insumos,
                  producto: producto.value!,
                ),
              )
                  .then((value) {
                const snackbar =
                    SnackBar(content: Text("Produccion guardada con exito"));
                ScaffoldMessenger.of(context).showSnackBar(snackbar);

                Navigator.of(context).pop();
              }).catchError(
                (err) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Guardar Produccion"),
                        content: const Text(
                            "Hubo un error al guardar la Produccion"),
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
              "Agregar Insumo",
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
                "Insumo",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
            StreamBuilder(
                stream: productosInsumoStream,
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
                  productos.value = snap.data!.docs;
                  return Obx(
                    () => DropdownButton<DocumentReference<Producto>>(
                      value: productoInsumo.value,
                      onChanged: (text) {
                        if (text != null) {
                          productoInsumo.value = text;
                        }
                      },
                      items: productos.map(
                        (e) {
                          return DropdownMenuItem(
                            value: e.reference,
                            child: Text(e.data().producto),
                          );
                        },
                      ).toList(),
                    ),
                  );
                }),
            TextField(
              controller: cantidad,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Cantidad",
                labelText:
                    "Cantidad usada ${productoInsumo.value != null ? productos.firstWhere(
                          (p0) => p0.reference == productoInsumo.value,
                        ).data().unidad : ""} ",
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
                    if (cantidad.text.trim().isEmpty ||
                        productoInsumo.value == null) {
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
                    insumos.add(
                      DetalleInsumo(
                        cantidad: cantidad.text,
                        producto: productoInsumo.value!.id,
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
