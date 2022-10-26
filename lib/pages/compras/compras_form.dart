import 'package:flutter/material.dart';

class ComprasForm extends StatefulWidget {
  const ComprasForm({super.key});

  @override
  State<ComprasForm> createState() => _ComprasFormState();
}

class _ComprasFormState extends State<ComprasForm> {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
    appBar:  AppBar(title: const Text("Compras Form"),),
      body:  const Center(
        child: Text("Compras Form"),
      ),
    );
  }
}
