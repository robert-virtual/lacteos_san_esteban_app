import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user_) {
      if (user_ != null) {
        Navigator.of(context).popAndPushNamed("/home");
      }
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
                        email: email.text.trim(), password: password.text);
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
