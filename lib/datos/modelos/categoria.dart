import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Un grupo de productos: Postres, Antojos, Bebidas…
class Categoria {
  const Categoria({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.colores,
  });

  /// Una categoría en blanco, que todavía no se ha guardado.
  const Categoria.nueva()
    : id = '',
      nombre = '',
      emoji = '🍽️',
      colores = Pasteles.rosa;

  /// Vacío mientras la categoría no se haya guardado (ver [esNueva]).
  final String id;

  final String nombre;
  final String emoji;

  /// Colores con los que se pintan sus productos.
  final ParDeColores colores;

  bool get esNueva => id.isEmpty;

  /// Emoji y nombre juntos: "🍰 Postres".
  String get etiqueta => '$emoji $nombre';

  /// Devuelve una copia con los campos indicados cambiados.
  Categoria copiarCon({
    String? id,
    String? nombre,
    String? emoji,
    ParDeColores? colores,
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      emoji: emoji ?? this.emoji,
      colores: colores ?? this.colores,
    );
  }
}
