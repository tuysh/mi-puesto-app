import 'package:mi_puesto/datos/modelos/dinero.dart';

/// Algo que el puesto vende.
class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    required this.nombreCorto,
    required this.emoji,
    required this.precio,
    required this.costo,
    required this.categoriaId,
    this.letras = '',
    this.fotoUrl = '',
    this.aLaVenta = true,
  });

  /// Un producto en blanco, que todavía no se ha guardado.
  const Producto.nuevo({required this.categoriaId})
    : id = '',
      nombre = '',
      nombreCorto = '',
      emoji = '🍽️',
      precio = Dinero.cero,
      costo = Dinero.cero,
      letras = '',
      fotoUrl = '',
      aLaVenta = true;

  /// Vacío mientras el producto no se haya guardado (ver [esNuevo]).
  final String id;

  final String nombre;

  /// Nombre abreviado que cabe en el botón del producto al vender.
  final String nombreCorto;

  /// Un producto se ve en los botones de una de tres maneras: con su foto,
  /// con un emoji o con letras. Se usa lo primero que tenga, en ese orden;
  /// lo que no se usa queda vacío.
  final String emoji;

  /// Hasta dos letras, para cuando ningún emoji se parece: "PL".
  final String letras;

  /// La dirección de la foto en internet; vacía si no tiene foto.
  final String fotoUrl;

  /// Lo que paga el cliente.
  final Dinero precio;

  /// Lo que le cuesta al puesto.
  final Dinero costo;

  final String categoriaId;

  /// Si es `false`, el producto está oculto y no aparece al vender.
  final bool aLaVenta;

  bool get esNuevo => id.isEmpty;

  /// Lo que se gana por cada pieza vendida.
  Dinero get ganancia => precio - costo;

  /// Devuelve una copia con los campos indicados cambiados.
  Producto copiarCon({
    String? id,
    String? nombre,
    String? nombreCorto,
    String? emoji,
    String? letras,
    String? fotoUrl,
    Dinero? precio,
    Dinero? costo,
    String? categoriaId,
    bool? aLaVenta,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      nombreCorto: nombreCorto ?? this.nombreCorto,
      emoji: emoji ?? this.emoji,
      letras: letras ?? this.letras,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      precio: precio ?? this.precio,
      costo: costo ?? this.costo,
      categoriaId: categoriaId ?? this.categoriaId,
      aLaVenta: aLaVenta ?? this.aLaVenta,
    );
  }
}
