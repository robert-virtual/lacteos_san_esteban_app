import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';
import 'package:lacteos_san_esteban_app/pages/clientes/clientes.dart';
import 'package:lacteos_san_esteban_app/pages/compras/compras_page.dart';
import 'package:lacteos_san_esteban_app/pages/empleados/empleados.dart';
import 'package:lacteos_san_esteban_app/pages/produccion/produccion_page.dart';
import 'package:lacteos_san_esteban_app/pages/proveedores/proveedores.dart';
import 'package:lacteos_san_esteban_app/pages/ventas/ventas_page.dart';
import 'package:get/get.dart';

class HomePageArgs {
  DocumentReference<Persona>? cliente;
  DocumentReference<Persona>? proveedor;
  DocumentReference<Persona>? empleado;
  int idx;
  HomePageArgs(
      {required this.idx, this.proveedor, this.cliente, this.empleado});
}

class HomePage extends StatelessWidget {
  HomePage({super.key});
  static const routeName = "/home";
  var currentPage = 0.obs;
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as HomePageArgs?;
    if (args != null) {
      currentPage.value = args.idx;
    }
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: currentPage.value,
          children: [
            VentasPage(cliente: args?.cliente, empleado: args?.empleado),
            ComprasPage(proveedor: args?.proveedor, empleado: args?.empleado),
            ProduccionPage(empleado: args?.empleado),
            ClientesPage(),
            ProveedoresPage(),
            EmpleadosPage()
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: currentPage.value,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).disabledColor,
          onTap: (idx) => currentPage.value = idx,
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
              label: "Empleados",
              icon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}
