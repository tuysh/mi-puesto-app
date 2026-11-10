import 'dart:typed_data';

/// Una foto recién tomada o elegida de la galería, que todavía no se ha
/// subido al servidor.
class FotoNueva {
  const FotoNueva({required this.bytes, required this.nombreDeArchivo});

  /// El contenido del archivo de imagen.
  final Uint8List bytes;

  /// Por ejemplo `foto.jpg`. Con la terminación el servidor sabe qué tipo
  /// de imagen es.
  final String nombreDeArchivo;
}
