import 'package:flutter/material.dart';

class ProduccionPage extends StatefulWidget {
  const ProduccionPage({super.key});

  @override
  State<ProduccionPage> createState() => _ProduccionPageState();
}

class _ProduccionPageState extends State<ProduccionPage> {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
    appBar:  AppBar(title: const Text("Produccion"),),
      body:  const Center(
        child: Text("Produccion"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/compras_form");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
