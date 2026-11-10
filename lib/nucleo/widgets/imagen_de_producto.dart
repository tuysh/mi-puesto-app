import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/visual_de_producto.dart';

/// Cuadrito redondeado con la foto, el emoji o las letras de un producto,
/// sobre el color de su categoría.
class ImagenDeProducto extends StatelessWidget {
  const ImagenDeProducto({
    super.key,
    required this.nombre,
    required this.colores,
    this.emoji = '',
    this.letras = '',
    this.fotoUrl = '',
    this.fotoLocal,
    this.tamano = 42,
  });

  /// La imagen de [producto], tal como está guardado.
  ImagenDeProducto.de(
    Producto producto, {
    super.key,
    required this.colores,
    this.tamano = 42,
  }) : nombre = producto.nombre,
       emoji = producto.emoji,
       letras = producto.letras,
       fotoUrl = producto.fotoUrl,
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(tamano / 3),
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
