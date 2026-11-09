import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Un grupo de productos: Postres, Antojos, Bebidas…
class Categoria {
  const Categoria({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.colores,
  });

  final String id;
  final String nombre;
  final String emoji;

  /// Colores con los que se pintan sus productos.
  final ParDeColores colores;

  /// Emoji y nombre juntos: "🍰 Postres".
  String get etiqueta => '$emoji $nombre';
}
