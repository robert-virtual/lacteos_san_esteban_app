import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';

class Compra {
  DocumentReference<Persona> proveedor;
  DocumentReference<Persona> empleado;
  List<DetalleVenta> detalles;
  Timestamp fecha;
  Compra({
    required this.proveedor,
    required this.empleado,
    required this.fecha,
    required this.detalles,
  });
  factory Compra.fromJson(Map<String, dynamic> map) {
    return Compra(
      empleado: (map["empleado"] as DocumentReference).withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (empleado, _) => empleado.toJson()),
      proveedor: (map["proveedor"] as DocumentReference).withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (proveedor, _) => proveedor.toJson()),
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
      "proveedor": proveedor,
      "empleado": empleado,
      "fecha": fecha,
      "detalles": detalles.map((e) => e.toJson()).toList()
    };
  }
}
