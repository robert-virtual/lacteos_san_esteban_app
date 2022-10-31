import 'package:flutter/material.dart';
import 'package:lacteos_san_esteban_app/pages/clientes/clientes.dart';
import 'package:lacteos_san_esteban_app/pages/compras/compras_page.dart';
import 'package:lacteos_san_esteban_app/pages/cuenta/cuenta_page.dart';
import 'package:lacteos_san_esteban_app/pages/produccion/produccion_page.dart';
import 'package:lacteos_san_esteban_app/pages/proveedores/proveedores.dart';
import 'package:lacteos_san_esteban_app/pages/ventas/ventas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentPage, children: [
        VentasPage(),
        ComprasPage(),
        ProduccionPage(),
        ClientesPage(),
        ProveedoresPage(),
        const CuentaPage()
      ]),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentPage,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).disabledColor,
          onTap: (idx) => setState(() => currentPage = idx),
          items: const [
            BottomNavigationBarItem(
              label: "Ventas",
              icon: Icon(Icons.sell),
            ),
            BottomNavigationBarItem(
              label: "Compras",
              icon: Icon(Icons.local_mall),
            ),
            BottomNavigationBarItem(
              label: "Produccion",
              icon: Icon(Icons.factory),
            ),
            BottomNavigationBarItem(
              label: "Clientes",
              icon: Icon(Icons.people),
            ),
            BottomNavigationBarItem(
              label: "Proveedores",
              icon: Icon(Icons.local_shipping),
            ),
            BottomNavigationBarItem(
              label: "Cuenta",
              icon: Icon(Icons.person),
            ),
          ]),
    );
  }
}
