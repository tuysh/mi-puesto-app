import 'package:mi_puesto/datos/modelos/foto_nueva.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';

/// Cómo quiere la persona que se vea un producto al vender. Es lo que
/// devuelve la hoja "¿Cómo se ve al vender?" (ver `elegirImagen`).
///
/// Se usa lo primero que haya: la foto, el emoji o las letras.
class ImagenElegida {
  const ImagenElegida({
    this.emoji = '',
    this.letras = '',
    this.fotoUrl = '',
    this.fotoNueva,
  });

  /// La imagen que [producto] ya tiene guardada.
  ImagenElegida.de(Producto producto)
    : emoji = producto.emoji,
      letras = producto.letras,
      fotoUrl = producto.fotoUrl,
      fotoNueva = null;

  final String emoji;
  final String letras;

  /// La foto que el producto ya tenía en el servidor, si se conserva.
  final String fotoUrl;

  /// Una foto recién tomada o elegida; se sube al guardar el producto.
  final FotoNueva? fotoNueva;

  bool get tieneFoto => fotoNueva != null || fotoUrl.isNotEmpty;
}
