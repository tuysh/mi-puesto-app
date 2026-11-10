import 'dart:math';

/// Genera un identificador único (UUID versión 4), por ejemplo
/// `3f2b8c1e-9d4a-4f6b-8a57-0c1d2e3f4a5b`.
///
/// Cada venta lleva uno: si la venta se manda dos veces por mala señal, el
/// servidor reconoce el identificador y no la registra doble.
String crearUuid() {
  final azar = Random.secure();
  final bytes = List<int>.generate(16, (_) => azar.nextInt(256));

  // Estos dos ajustes marcan el identificador como "versión 4, al azar".
  bytes[6] = (bytes[6] & 0x0F) | 0x40;
  bytes[8] = (bytes[8] & 0x3F) | 0x80;

  final hex = [for (final byte in bytes) byte.toRadixString(16).padLeft(2, '0')]
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
