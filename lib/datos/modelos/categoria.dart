import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Un grupo de productos (Postres, Bebidas…) o de gastos (Gas, Plaza…).
/// Las dos clases de categoría tienen la misma forma.
class Categoria {
  const Categoria({
    required this.id,
    required this.nombre,
    required this.color,
    this.usos = 0,
  });

  final String id;
  final String nombre;

  /// Número del pastel que le toca, de 0 a 4 (ver `Pasteles.todos`).
  /// Lo reparte el servidor al crearla.
  final int color;

  /// Cuántos productos (o gastos) tiene esta categoría.
  final int usos;

  /// Colores con los que se pintan sus productos y su etiqueta.
  ParDeColores get colores => Pasteles.paraIndice(color);
}
