import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Una persona que vende en el puesto.
class Vendedor {
  const Vendedor({
    required this.id,
    required this.nombre,
    required this.colores,
  });

  final String id;
  final String nombre;

  /// Colores de su círculo con la inicial.
  final ParDeColores colores;

  /// Primera letra del nombre, en mayúscula: "Mari" → "M".
  String get inicial => nombre.isEmpty ? '?' : nombre[0].toUpperCase();
}
