/// Propone las letras para el botón de un producto a partir de su nombre:
///
/// - "Pay de limón" → "PL" (las iniciales de sus dos primeras palabras,
///   sin contar las cortitas como "de" o "con");
/// - "Tostilocos" → "To" (si es una sola palabra, sus dos primeras letras).
String sugerirLetras(String nombre) {
  final palabras = nombre.trim().split(RegExp(r'\s+'));
  final palabrasLargas = [
    for (final palabra in palabras)
      if (palabra.length > 2) palabra,
  ];
  // Si todas son cortitas ("Té"), se usan como vengan.
  final utiles = palabrasLargas.isEmpty ? palabras : palabrasLargas;

  if (utiles.first.isEmpty) return '';
  if (utiles.length == 1) {
    final palabra = utiles.first;
    final inicio = palabra.substring(0, palabra.length < 2 ? 1 : 2);
    return inicio[0].toUpperCase() + inicio.substring(1).toLowerCase();
  }
  return (utiles[0][0] + utiles[1][0]).toUpperCase();
}
