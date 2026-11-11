import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/presentacion.dart';

/// Con qué se pinta un producto en los botones.
enum Representacion { imagen, emoji, letras }

/// Algo que el puesto vende.
///
/// Un producto tiene UN precio o VARIOS tamaños ([presentaciones]), cada
/// uno con el suyo; nunca las dos cosas.
class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    required this.categoriaId,
    required this.precio,
    this.presentaciones = const [],
    this.representacion = Representacion.letras,
    this.emoji = '',
    this.letras = '',
    this.imagenUrl = '',
    this.disponible = true,
  });

  /// Un producto en blanco, que todavía no se ha guardado.
  const Producto.nuevo({this.categoriaId})
    : id = '',
      nombre = '',
      precio = Dinero.cero,
      presentaciones = const [],
      representacion = Representacion.letras,
      emoji = '',
      letras = '',
      imagenUrl = '',
      disponible = true;

  /// Vacío mientras el producto no se haya guardado (ver [esNuevo]).
  final String id;

  final String nombre;

  /// `null` si el producto no tiene categoría.
  final String? categoriaId;

  /// Lo que paga el cliente. Es `null` cuando el producto tiene tamaños.
  final Dinero? precio;

  /// Los tamaños; vacío si el producto se vende a un solo precio.
  final List<Presentacion> presentaciones;

  /// Cuál de las tres cosas de abajo se pinta. Las otras dos pueden venir
  /// llenas, pero no se usan.
  final Representacion representacion;

  final String emoji;

  /// Hasta dos letras, para cuando ningún emoji se parece: "To".
  final String letras;

  /// La dirección de la foto en internet.
  final String imagenUrl;

  /// "Hay hoy". Con `false` se ve apagado al vender y no se puede agregar.
  final bool disponible;

  bool get esNuevo => id.isEmpty;

  bool get tieneTamanos => presentaciones.isNotEmpty;

  /// El precio que se muestra en el botón: el único que tiene o, si tiene
  /// tamaños, el del más barato ("desde $15").
  Dinero get precioDesde {
    if (!tieneTamanos) return precio ?? Dinero.cero;

    var menor = presentaciones.first.precio;
    for (final presentacion in presentaciones) {
      if (presentacion.precio < menor) menor = presentacion.precio;
    }
    return menor;
  }

  /// Devuelve una copia con los campos indicados cambiados.
  Producto copiarCon({
    String? id,
    Representacion? representacion,
    String? emoji,
    String? letras,
    String? imagenUrl,
    bool? disponible,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre,
      categoriaId: categoriaId,
      precio: precio,
      presentaciones: presentaciones,
      representacion: representacion ?? this.representacion,
      emoji: emoji ?? this.emoji,
      letras: letras ?? this.letras,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      disponible: disponible ?? this.disponible,
    );
  }
}
