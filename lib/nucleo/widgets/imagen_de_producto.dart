import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/visual_de_producto.dart';

/// Cuadrito redondeado con la foto, el emoji o las letras de un producto,
/// sobre el color de su categoría.
class ImagenDeProducto extends StatelessWidget {
  /// Dibuja lo primero que se le dé, en este orden: [fotoLocal], [fotoUrl],
  /// [emoji], [letras]. Para pintar un producto guardado es más fácil
  /// [ImagenDeProducto.de].
  const ImagenDeProducto({
    super.key,
    required this.nombre,
    required this.colores,
    this.emoji = '',
    this.letras = '',
    this.fotoUrl = '',
    this.fotoLocal,
    this.tamano = 42,
    this.radio,
  });

  /// La imagen de [producto], tal como está guardado.
  ImagenDeProducto.de(
    Producto producto, {
    super.key,
    required this.colores,
    this.tamano = 42,
    this.radio,
  }) : nombre = producto.nombre,
       emoji = _emojiQueSePinta(producto.representacion, producto.emoji),
       letras = producto.letras,
       fotoUrl = _fotoQueSePinta(producto.representacion, producto.imagenUrl),
       fotoLocal = null;

  /// La imagen de un producto de "Lo más vendido".
  ImagenDeProducto.deVendido(
    ProductoVendido vendido, {
    super.key,
    required this.colores,
    this.tamano = 42,
    this.radio,
  }) : nombre = vendido.nombreDelProducto,
       emoji = _emojiQueSePinta(vendido.representacion, vendido.emoji),
       letras = vendido.letras,
       fotoUrl = _fotoQueSePinta(vendido.representacion, vendido.imagenUrl),
       fotoLocal = null;

  final String nombre;

  /// Los colores de la categoría: el fondo del cuadro y la tinta de las
  /// letras.
  final ParDeColores colores;

  final String emoji;
  final String letras;
  final String fotoUrl;

  /// Una foto recién elegida que todavía no se sube.
  final Uint8List? fotoLocal;

  /// Lado del cuadro.
  final double tamano;

  /// Radio de las esquinas. Si es `null`, un tercio del lado.
  final double? radio;

  /// El servidor dice con qué se pinta el producto ([representacion]); lo
  /// demás puede venir lleno, pero no se usa. Si se pinta con letras, el
  /// emoji se ignora. Si se pinta con foto, el emoji se deja pasar: es lo
  /// que se ve cuando la foto no carga.
  static String _emojiQueSePinta(Representacion representacion, String emoji) {
    return representacion == Representacion.letras ? '' : emoji;
  }

  static String _fotoQueSePinta(Representacion representacion, String url) {
    return representacion == Representacion.imagen ? url : '';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radio ?? tamano / 3),
      child: Container(
        width: tamano,
        height: tamano,
        color: colores.fondo,
        child: VisualDeProducto(
          nombre: nombre,
          tinta: colores.tinta,
          tamanoDeEmoji: tamano * 0.52,
          tamanoDeLetras: tamano * 0.44,
          emoji: emoji,
          letras: letras,
          fotoUrl: fotoUrl,
          fotoLocal: fotoLocal,
        ),
      ),
    );
  }
}
