import 'package:flutter/material.dart';

class ProduccionForm extends StatefulWidget {
  const ProduccionForm({super.key});

  @override
  State<ProduccionForm> createState() => _ProduccionFormState();
}

class _ProduccionFormState extends State<ProduccionForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compras Form"),
      ),
      body: const Center(
        child: Text("Compras Form"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text("Agregar Producto"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
