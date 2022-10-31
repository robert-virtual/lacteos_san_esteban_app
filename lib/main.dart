import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lacteos_san_esteban_app/pages/clientes/clientes_form.dart';
import 'package:lacteos_san_esteban_app/pages/compras/compras_form.dart';
import 'package:lacteos_san_esteban_app/pages/cuenta/cuenta_page.dart';
import 'package:lacteos_san_esteban_app/pages/home_page.dart';
import 'package:lacteos_san_esteban_app/pages/login_page.dart';
import 'package:lacteos_san_esteban_app/pages/produccion/produccion_form.dart';
import 'package:lacteos_san_esteban_app/pages/ventas/ventas_form.dart';
import 'firebase_options.dart';
/* import 'package:firebase_auth/firebase_auth.dart'; */

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  /* await FirebaseAuth.instance.useAuthEmulator('localhost', 9099); */
  FirebaseAuth.instanceFor(app: Firebase.app(), persistence: Persistence.LOCAL);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.orange),
    /* darkTheme: ThemeData.dark(), */
    initialRoute:
        FirebaseAuth.instance.currentUser != null ? "/home" : "/login",
    routes: {
      "/login": (context) => const LoginPage(),
      "/home": (context) => const HomePage(),
      "/compras_form": (context) =>  ComprasForm(),
      "/ventas_form": (context) => VentasForm(),
      "/produccion_form": (context) => const ProduccionForm(),
      "/cuenta": (context) => const CuentaPage(),
      "/clientes_form": (context) => ClientesForm(),
    },
  ));
}
