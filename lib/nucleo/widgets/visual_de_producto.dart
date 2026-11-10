import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Lo que representa a un producto: su foto, su emoji o sus letras.
///
/// Se dibuja lo primero que haya, en este orden: [fotoLocal], [fotoUrl],
/// [emoji], [letras]. Si no hay nada, la inicial de [nombre].
///
/// Llena todo el espacio que le den y no tiene fondo ni esquinas: eso lo
/// pone quien lo usa (ver `ImagenDeProducto` y `TeselaDeProducto`).
class VisualDeProducto extends StatelessWidget {
  const VisualDeProducto({
    super.key,
    required this.nombre,
    required this.tinta,
    required this.tamanoDeEmoji,
    required this.tamanoDeLetras,
    this.emoji = '',
    this.letras = '',
    this.fotoUrl = '',
    this.fotoLocal,
  });

  /// El nombre del producto; de aquí sale la inicial de último recurso.
  final String nombre;

  /// Color de las letras (la tinta de la categoría).
  final Color tinta;

  final double tamanoDeEmoji;
  final double tamanoDeLetras;

  final String emoji;
  final String letras;

  /// Dirección de la foto en internet.
  final String fotoUrl;

  /// Una foto recién elegida que todavía no se sube.
  final Uint8List? fotoLocal;

  @override
  Widget build(BuildContext context) {
    final fotoLocal = this.fotoLocal;
    if (fotoLocal != null) return _foto(MemoryImage(fotoLocal));

    if (fotoUrl.startsWith('data:')) {
      // Con datos simulados la imagen viene dentro de la propia dirección.
      return _foto(MemoryImage(UriData.parse(fotoUrl).contentAsBytes()));
    }
    if (fotoUrl.isNotEmpty) return _foto(NetworkImage(fotoUrl));

    return _emojiOLetras();
  }

  /// La foto se recorta sola para llenar el espacio, sin deformarse.
  Widget _foto(ImageProvider imagen) {
    return Image(
      image: imagen,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      // Solo adorna: el nombre del producto ya está escrito al lado.
      excludeFromSemantics: true,
      // Sin internet (o si la foto ya no existe) se ve el emoji o las
      // letras, en vez de un hueco.
      errorBuilder: (context, error, pila) {
        // Deja el motivo en la consola para quien esté programando.
        debugPrint('No se pudo mostrar la foto $fotoUrl: $error');
        return _emojiOLetras();
      },
    );
  }

  Widget _emojiOLetras() {
    if (emoji.isNotEmpty) {
      return Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: tamanoDeEmoji, height: 1.1),
        ),
      );
    }

    return Center(
      child: Text(
        letras.isNotEmpty ? letras : _inicial,
        maxLines: 1,
        style: Tipografia.titulo(tamanoDeLetras, color: tinta),
      ),
    );
  }

  String get _inicial {
    final limpio = nombre.trim();
    return limpio.isEmpty ? '?' : limpio.characters.first.toUpperCase();
  }
}
