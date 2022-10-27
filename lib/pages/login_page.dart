import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  CollectionReference empleados =
      FirebaseFirestore.instance.collection("empleados").withConverter<Persona>(
            fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
            toFirestore: (empleado, _) => empleado.toJson(),
          );
  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user_) {
      if (user_ == null) {
        return;
      }
      empleados.doc(user_.email).get().then((value) {
        if (value.exists) {
          Navigator.of(context).popAndPushNamed("/home");
          return;
        }
        Navigator.of(context).popAndPushNamed("/cuenta");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset("/images/san_esteban.jpg"),
              const Text(
                "Iniciar Sesion",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: email,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email), label: Text("Correo")),
              ),
              TextField(
                keyboardType: TextInputType.visiblePassword,
                controller: password,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.password), label: Text("Clave")),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ButtonStyle(
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(10.0))),
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email.text.trim(),
                      password: password.text,
                    );
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Inicio de sesion fallido"),
                        content: const Text(
                          "Credenciales incorrectas. Verifica que hayas insertado tu correo y clave correctamente",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("OK"),
                          )
                        ],
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Entrar",
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Icon(
                      Icons.login,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
