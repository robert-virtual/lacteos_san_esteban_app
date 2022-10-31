import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';

class DetalleInsumo {
  int cantidad;
  String producto;
  String unidadMedida;
  DetalleInsumo(
      {required this.unidadMedida,
      required this.cantidad,
      required this.producto});
  factory DetalleInsumo.fromJson(Map<String, dynamic> map) {
    return DetalleInsumo(
      producto: map["producto"],
      unidadMedida: map["unidad_medida"],
      cantidad: map["cantidad"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "producto": producto,
      "unidad_medida": unidadMedida,
      "cantidad": cantidad,
    };
  }
}

class Produccion {
  DocumentReference<Persona> empleado;
  DocumentReference<Producto> producto;
  List<DetalleInsumo> insumos;
  double cantidadProducida;
  String unidadMedida;
  Timestamp fecha;
  Produccion({
    required this.unidadMedida,
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
      cantidadProducida: double.parse("${map["cantidad"]}"),
      fecha: map["fecha"],
      unidadMedida: map["unidad_medida"],
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
      "unidad_medida": unidadMedida,
    };
  }
}
