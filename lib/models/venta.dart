import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Producto {
  String producto;
  Producto({required this.producto});
  factory Producto.fromJson(Map<String, dynamic> map) {
    return Producto(producto: map["producto"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "producto": producto,
    };
  }
}

class DetalleVenta {
  int cantidad;
  double precio;
  Producto? producto;
  String unidadMedida;
  DetalleVenta(
      {required this.unidadMedida,
      required this.cantidad,
      required this.precio,
      this.producto});
  factory DetalleVenta.fromJson(Map<String, dynamic> map) {
    return DetalleVenta(
      unidadMedida: map["unidad_medida"],
      precio: (map["precio"] as int).toDouble(),
      cantidad: map["cantidad"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "unidad_medida": unidadMedida,
      "precio": precio,
      "cantidad": cantidad,
    };
  }
}

class Persona {
  String correo;
  String direccion;
  String telefono;
  String nombre;
  Timestamp fechaRegistro;
  Persona({
    required this.correo,
    required this.fechaRegistro,
    required this.direccion,
    required this.telefono,
    required this.nombre,
  });

  factory Persona.fromJson(Map<String, dynamic> map) {
    return Persona(
        correo: map["correo"],
        fechaRegistro: map["fecha_registro"],
        direccion: map["direccion"],
        telefono: map["telefono"],
        nombre: map["nombre"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "fecha_registro": fechaRegistro,
      "correo": correo,
      "direccion": direccion,
      "telefono": telefono,
      "nombre": nombre
    };
  }
}

class Venta {
  DocumentReference<Persona> cliente;
  DocumentReference<Persona> empleado;
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
      empleado: (map["empleado"] as DocumentReference).withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (empleado, _) => empleado.toJson()),
      cliente: (map["cliente"] as DocumentReference).withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
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
