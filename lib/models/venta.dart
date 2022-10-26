import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  String producto;
  bool compra;
  Producto({required this.producto, required this.compra});
  factory Producto.fromJson(Map<String, dynamic> map) {
    return Producto(compra: map["compra"], producto: map["producto"]);
  }
}

class DetalleVenta {
  int cantidad;
  double precio;
  Producto? producto;
  DetalleVenta({required this.cantidad, required this.precio, this.producto});
  factory DetalleVenta.fromJson(Map<String, dynamic> map) {
    return DetalleVenta(
      precio: (map["precio"] as int).toDouble(),
      cantidad: map["cantidad"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "precio": precio,
      "cantidad": cantidad,
    };
  }
}

class Cliente {
  String correo;
  String direccion;
  String telefono;
  String nombre;
  Cliente({
    required this.correo,
    required this.direccion,
    required this.telefono,
    required this.nombre,
  });

  factory Cliente.fromJson(Map<String, dynamic> map) {
    return Cliente(
        correo: map["correo"],
        direccion: map["direccion"],
        telefono: map["telefono"],
        nombre: map["nombre"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "correo": correo,
      "direccion": direccion,
      "telefono": telefono,
      "nombre": nombre
    };
  }
}

class Venta {
  DocumentReference<Cliente> cliente;
  String empleado;
  List<DetalleVenta> detalles;
  Timestamp fecha;
  Venta({
    required this.cliente,
    required this.empleado,
    required this.fecha,
    required this.detalles,
  });
  factory Venta.fromJson(Map<String, dynamic> map) {
    return Venta(
      empleado: map["empleado"],
      cliente: (map["cliente"] as DocumentReference).withConverter<Cliente>(
          fromFirestore: (snap, _) => Cliente.fromJson(snap.data()!),
          toFirestore: (cliente, _) => cliente.toJson()),
      fecha: map["fecha"],
      detalles: List.from(map["detalles"])
          .map(
            (e) => DetalleVenta.fromJson(e),
          )
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "empleado": empleado,
      "fecha": fecha,
      "detalles": detalles.map((e) => e.toJson())
    };
  }
}
