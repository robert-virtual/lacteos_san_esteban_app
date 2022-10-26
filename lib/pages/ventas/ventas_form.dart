import 'package:flutter/material.dart';

class VentasForm extends StatefulWidget {
  const VentasForm({super.key});

  @override
  State<VentasForm> createState() => _VentasFormState();
}

class _VentasFormState extends State<VentasForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compras Form"),
      ),
      body: Center(
        child: Column(
          children: [
            const Text("Compras Form"),
            /* TextField(controller: ,) */
          ],
        ),
      ),
    );
  }
}
