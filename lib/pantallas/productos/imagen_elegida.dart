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
  ///
  /// El servidor guarda las tres cosas, pero solo una se pinta
  /// (`representacion`); aquí se dejan pasar nada más las que hacen falta.
  factory ImagenElegida.de(Producto producto) {
    return switch (producto.representacion) {
      // El emoji y las letras se conservan: son lo que se ve si la foto no
      // carga.
      Representacion.imagen => ImagenElegida(
        emoji: producto.emoji,
        letras: producto.letras,
        fotoUrl: producto.imagenUrl,
      ),
      Representacion.emoji => ImagenElegida(emoji: producto.emoji),
      Representacion.letras => ImagenElegida(letras: producto.letras),
    };
  }

  final String emoji;
  final String letras;

  /// La foto que el producto ya tenía en el servidor, si se conserva.
  final String fotoUrl;

  /// Una foto recién tomada o elegida; se sube al guardar el producto.
  final FotoNueva? fotoNueva;

  bool get tieneFoto => fotoNueva != null || fotoUrl.isNotEmpty;

  /// Con cuál de las tres cosas se va a pintar el producto.
  Representacion get representacion {
    if (tieneFoto) return Representacion.imagen;
    if (emoji.isNotEmpty) return Representacion.emoji;
    return Representacion.letras;
  }
}
