import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';

class DetalleInsumo {
  String cantidad;
  String producto;
  DetalleInsumo({required this.cantidad, required this.producto});
  factory DetalleInsumo.fromJson(Map<String, dynamic> map) {
    return DetalleInsumo(
      producto: map["producto"],
      cantidad: map["cantidad"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "producto": producto,
      "cantidad": cantidad,
    };
  }
}

class Produccion {
  DocumentReference<Persona> empleado;
  DocumentReference<Producto> producto;
  List<DetalleInsumo> insumos;
  String cantidadProducida;
  Timestamp fecha;
  Produccion({
    required this.producto,
    required this.cantidadProducida,
    required this.empleado,
    required this.fecha,
    required this.insumos,
  });
  factory Produccion.fromJson(Map<String, dynamic> map) {
    return Produccion(
      producto: (map["producto"] as DocumentReference).withConverter<Producto>(
          fromFirestore: (snap, _) => Producto.fromJson(snap.data()!),
          toFirestore: (producto, _) => producto.toJson()),
      empleado: (map["empleado"] as DocumentReference).withConverter<Persona>(
          fromFirestore: (snap, _) => Persona.fromJson(snap.data()!),
          toFirestore: (empleado, _) => empleado.toJson()),
      cantidadProducida: map["cantidad"],
      fecha: map["fecha"],
      insumos: List.from(map["insumos"])
          .map(
            (e) => DetalleInsumo.fromJson(e),
          )
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "cantidad": cantidadProducida,
      "empleado": empleado,
      "fecha": fecha,
      "insumos": insumos.map((e) => e.toJson()).toList(),
      "producto": producto,
    };
  }
}
