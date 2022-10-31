import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  String producto;
  bool? compra;
  bool? insumo;
  bool? venta;
  String? unidad;
  Producto(
      {this.venta,
      this.compra,
      this.insumo,
      this.unidad,
      required this.producto});
  factory Producto.fromJson(Map<String, dynamic> map) {
    return Producto(
      unidad: map["unidad"],
      compra: map["compra"],
      venta: map["venta"],
      insumo: map["insumo"],
      producto: map["producto"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "producto": producto,
    };
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class DetalleVenta {
  int cantidad;
  double precio;
  DocumentReference<Producto> producto;
  String unidadMedida;
  DetalleVenta(
      {required this.unidadMedida,
      required this.cantidad,
      required this.precio,
      required this.producto});
  factory DetalleVenta.fromJson(Map<String, dynamic> map) {
    return DetalleVenta(
      producto: (map["producto"] as DocumentReference).withConverter<Producto>(
          fromFirestore: (snap, _) => Producto.fromJson(snap.data()!),
          toFirestore: (producto, _) => producto.toJson()),
      unidadMedida: map["unidad_medida"],
      precio: double.parse("${map["precio"]}"),
      cantidad: map["cantidad"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "producto": producto,
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
      "cliente": cliente,
      "empleado": empleado,
      "fecha": fecha,
      "detalles": detalles.map((e) => e.toJson()).toList()
    };
  }
}
