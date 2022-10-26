import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CuentaPage extends StatefulWidget {
  const CuentaPage({super.key});

  @override
  State<CuentaPage> createState() => _CuentaPageState();
}

class _CuentaPageState extends State<CuentaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cuenta"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(FirebaseAuth.instance.currentUser!.email!),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).popAndPushNamed("/login");
              },
              child: const Text("Cerrar Sesion"),
            )
          ],
        ),
      ),
    );
  }
}
