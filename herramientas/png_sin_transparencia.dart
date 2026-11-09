import 'dart:io';
import 'dart:typed_data';

/// Convierte píxeles RGBA en un archivo PNG que NO tiene canal de
/// transparencia.
///
/// Hace falta porque la App Store rechaza los iconos con transparencia, y el
/// PNG que genera Flutter siempre la incluye aunque la imagen sea opaca.
Uint8List codificarPngSinTransparencia({
  required Uint8List rgba,
  required int lado,
}) {
  final cabecera = ByteData(13)
    ..setUint32(0, lado) // ancho
    ..setUint32(4, lado) // alto
    ..setUint8(8, 8) // bits por canal
    ..setUint8(9, 2); // tipo de color 2 = RGB, sin transparencia

  final pixeles = zlib.encode(_quitarTransparencia(rgba, lado));

  return Uint8List.fromList([
    ...[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A], // firma de PNG
    ..._bloque('IHDR', cabecera.buffer.asUint8List()),
    ..._bloque('IDAT', pixeles),
    ..._bloque('IEND', const []),
  ]);
}

/// Pasa de RGBA a RGB. El formato PNG pide además un byte al inicio de cada
/// fila que dice cómo está "filtrada"; 0 significa "sin filtro".
Uint8List _quitarTransparencia(Uint8List rgba, int lado) {
  final bytesPorFila = 1 + lado * 3;
  final rgb = Uint8List(bytesPorFila * lado);

  for (var fila = 0; fila < lado; fila++) {
    for (var columna = 0; columna < lado; columna++) {
      final origen = (fila * lado + columna) * 4;
      final destino = fila * bytesPorFila + 1 + columna * 3;
      rgb[destino] = rgba[origen]; // rojo
      rgb[destino + 1] = rgba[origen + 1]; // verde
      rgb[destino + 2] = rgba[origen + 2]; // azul
    }
  }
  return rgb;
}

/// Un bloque de PNG: tamaño, nombre, datos y código de verificación.
List<int> _bloque(String nombre, List<int> datos) {
  final nombreYDatos = [...nombre.codeUnits, ...datos];
  return [
    ..._enCuatroBytes(datos.length),
    ...nombreYDatos,
    ..._enCuatroBytes(_crc32(nombreYDatos)),
  ];
}

List<int> _enCuatroBytes(int numero) {
  return (ByteData(4)..setUint32(0, numero)).buffer.asUint8List();
}

/// El código de verificación estándar (CRC-32) que usa el formato PNG.
int _crc32(List<int> bytes) {
  var crc = 0xFFFFFFFF;
  for (final byte in bytes) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      crc = crc.isOdd ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
  }
  return crc ^ 0xFFFFFFFF;
}
