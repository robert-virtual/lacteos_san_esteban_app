import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';

class CuentaPage extends StatelessWidget {
  CuentaPage({super.key});
  final empleadosRef = FirebaseFirestore.instance
      .collection("empleados")
      .withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (empleado, _) => empleado.toJson());

  final bitacoraRef = FirebaseFirestore.instance.collection("bitacora");
  final nombre = TextEditingController(
      text: FirebaseAuth.instance.currentUser!.displayName);
  final direccion = TextEditingController();
  final telefono = TextEditingController(
      text: FirebaseAuth.instance.currentUser!.phoneNumber);
  final user = FirebaseAuth.instance.currentUser!;
  final futureEmpleado = FirebaseFirestore.instance
      .collection("empleados")
      .withConverter<Persona>(
        fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
        toFirestore: (empleado, _) => empleado.toJson(),
      )
      .doc(FirebaseAuth.instance.currentUser!.email)
      .withConverter<Persona>(
        fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
        toFirestore: (empleado, _) => empleado.toJson(),
      )
      .get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cuenta"),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("/login", (r) => false);
              });
            },
            child: const Text(
              "Cerrar Sesion",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
      body: FutureBuilder(
        future: futureEmpleado,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(
              child: Text("Ups ha ocurrido un error"),
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final empleado = snap.data!;
          if (empleado.exists) {
            telefono.text = empleado.data()!.telefono;
            direccion.text = empleado.data()!.direccion;
            nombre.text = empleado.data()!.nombre;
          }
          return Center(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
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
                  onPressed: () async {
                    if (nombre.text.trim().isEmpty ||
                        telefono.text.trim().isEmpty ||
                        direccion.text.trim().isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title:
                                const Text("Guardar informacion de empleado"),
                            content:
                                const Text("Debes ingresar todos los campos"),
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
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      if (!empleado.exists) {
                        final datos = Persona(
                          correo: user.email!,
                          direccion: direccion.text,
                          telefono: telefono.text,
                          nombre: nombre.text.trim().toLowerCase(),
                        );
                        await empleado.reference.update(
                          datos.toJson(),
                        );
                        bitacoraRef.add(
                          {
                            "correoEmpleado":
                                FirebaseAuth.instance.currentUser!.email,
                            "nombreEmpleado":
                                FirebaseAuth.instance.currentUser!.displayName,
                            "empleadoRef": empleadosRef
                                .doc(FirebaseAuth.instance.currentUser!.email),
                            "fecha": Timestamp.now(),
                            "accion": "Insertar Empleado",
                            "datos": datos.toJson()
                          },
                        );
                      } else {
                        final datos = Persona(
                          correo: user.email!,
                          fechaRegistro: empleado.data()!.fechaRegistro,
                          direccion: direccion.text,
                          telefono: telefono.text,
                          nombre: nombre.text,
                        );
                        await empleado.reference.set(
                          datos,
                        );
                        bitacoraRef.add(
                          {
                            "correoEmpleado":
                                FirebaseAuth.instance.currentUser!.email,
                            "nombreEmpleado":
                                FirebaseAuth.instance.currentUser!.displayName,
                            "empleadoRef": empleadosRef
                                .doc(FirebaseAuth.instance.currentUser!.email),
                            "fecha": Timestamp.now(),
                            "accion": "Actualizar empleado",
                            "datos": datos.toJson()
                          },
                        );
                      }
                      const snackBar = SnackBar(
                        content: Text("Informacion guardada con exito"),
                      );
                      scaffoldMessenger.showSnackBar(snackBar);
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title:
                                const Text("Guardar informacion de empleado"),
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
          );
        },
      ),
    );
  }
}
