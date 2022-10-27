import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';

class CuentaPage extends StatefulWidget {
  const CuentaPage({super.key});

  @override
  State<CuentaPage> createState() => _CuentaPageState();
}

class _CuentaPageState extends State<CuentaPage> {
  final nombre = TextEditingController(
      text: FirebaseAuth.instance.currentUser!.displayName);
  final direccion = TextEditingController();
  final telefono = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cuenta"),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.of(context).popAndPushNamed("/login");
              });
            },
            child: const Text(
              "Cerrar Sesion",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Informacion de empleado",
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              controller: nombre,
              decoration: const InputDecoration(
                label: Text("Nombre"),
                icon: Icon(Icons.person),
              ),
            ),
            TextField(
              controller: telefono,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: const InputDecoration(
                label: Text("Telefono"),
                icon: Icon(Icons.phone),
              ),
            ),
            TextField(
              controller: direccion,
              decoration: const InputDecoration(
                label: Text("Direccion"),
                icon: Icon(
                  Icons.location_on,
                ),
              ),
            ),
            TextField(
              enabled: false,
              controller: TextEditingController(text: user.email),
              decoration: const InputDecoration(
                label: Text("Correo"),
                icon: Icon(
                  Icons.location_on,
                ),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.all(10.0),
                ),
              ),
              onPressed: () {
                if (nombre.text.trim().isEmpty ||
                    telefono.text.trim().isEmpty ||
                    direccion.text.trim().isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Guardar informacion de empleado"),
                        content: const Text("Debes ingresar todos los campos"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("OK"),
                          )
                        ],
                      );
                    },
                  );
                  return;
                }
                try {
                  user.updateDisplayName(nombre.text);
                  CollectionReference empleados = FirebaseFirestore.instance
                      .collection("empleados")
                      .withConverter<Persona>(
                        fromFirestore: (snap, _) =>
                            Persona.fromJson(snap.data()!),
                        toFirestore: (empleado, _) => empleado.toJson(),
                      );
                  empleados.doc(user.email).set(
                        Persona(
                          correo: user.email!,
                          fechaRegistro: Timestamp.now(),
                          direccion: direccion.text,
                          telefono: telefono.text,
                          nombre: nombre.text,
                        ),
                      );
                  /* empleados.add( */
                  /*   , */
                  /* ); */
                  Navigator.of(context).popAndPushNamed("/home");
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Guardar informacion de empleado"),
                        content: const Text(
                            "No se pudo guardar la informacion. Intenta de nuevo"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("OK"),
                          )
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
