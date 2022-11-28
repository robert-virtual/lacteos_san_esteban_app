import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';

class ProductoForm extends StatelessWidget {
  ProductoForm({super.key});
  final bitacoraRef = FirebaseFirestore.instance.collection("bitacora");
  final empleadosRef = FirebaseFirestore.instance
      .collection("empleados")
      .withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (empleado, _) => empleado.toJson());
  // producto
  final nombre = TextEditingController();
  final unidad = TextEditingController();
  var compra = false.obs;
  var venta = false.obs;
  var insumo = false.obs;
  // producto

  final productosRef = FirebaseFirestore.instance
      .collection("tipos_productos")
      .withConverter<Producto>(
          fromFirestore: (snap, _) => Producto.fromJson(snap.data()!),
          toFirestore: (producto, _) => producto.toJson());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Producto")),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 25,
          left: 15,
          right: 15,
          bottom: 25,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nombre,
              decoration: const InputDecoration(
                label: Text("Nombre"),
              ),
            ),
            TextField(
              controller: unidad,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                label: Text("Unidad"),
              ),
            ),
            const Text("Compra: "),
            Obx(
              () => Checkbox(
                value: compra.value,
                onChanged: (value) => compra.value = !compra.value,
              ),
            ),
            const Text("Venta: "),
            Obx(
              () => Checkbox(
                value: venta.value,
                onChanged: (value) => venta.value = !venta.value,
              ),
            ),
            const Text("Insumo: "),
            Obx(
              () => Checkbox(
                value: insumo.value,
                onChanged: (value) => insumo.value = !insumo.value,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final res = productosRef.doc(unidad.text.trim());
          final producto = Producto(
              producto: nombre.text,
              unidad: unidad.text,
              venta: venta.value,
              compra: compra.value);
          res
              .set(
            producto,
          )
              .then(
            (value) {
              bitacoraRef.add(
                {
                  "correoEmpleado": FirebaseAuth.instance.currentUser!.email,
                  "nombreEmpleado":
                      FirebaseAuth.instance.currentUser!.displayName,
                  "empleadoRef": empleadosRef
                      .doc(FirebaseAuth.instance.currentUser!.email),
                  "fecha": Timestamp.now(),
                  "accion": "Insertar producto",
                  "datos": producto.toJson()
                },
              );
              Navigator.pop(context, res);
            },
          );
        },
        icon: const Icon(Icons.save),
        label: const Text("Guardar"),
      ),
    );
  }
}
