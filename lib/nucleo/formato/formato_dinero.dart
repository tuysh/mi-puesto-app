import 'dart:math';

import 'package:mi_puesto/datos/modelos/dinero.dart';

/// Convierte dinero a texto para mostrar: `$1,240` o `$12.50`.
/// Los centavos solo aparecen cuando no son cero.
String formatearDinero(Dinero monto) {
  final signo = monto.esNegativo ? '-' : '';
  return '$signo\$${formatearMontoEditable(monto.absoluto)}';
}

/// Igual que [formatearDinero] pero sin el signo de pesos: `1,240`.
/// Sirve como valor inicial de un campo donde se escribe dinero.
String formatearMontoEditable(Dinero monto) {
  final pesos = monto.centavos ~/ 100;
  final centavos = monto.centavos % 100;

  final textoDePesos = _separarMiles(pesos);
  if (centavos == 0) return textoDePesos;

  final textoDeCentavos = centavos.toString().padLeft(2, '0');
  return '$textoDePesos.$textoDeCentavos';
}

/// Lee dinero escrito por una persona: acepta `1735`, `1,735` o `$12.50`.
/// Devuelve `null` si el texto no es una cantidad válida.
Dinero? leerDinero(String texto) {
  final soloNumero = texto.replaceAll(',', '').replaceAll('\$', '').trim();
  final pesos = double.tryParse(soloNumero);
  if (pesos == null || pesos < 0) return null;

  return Dinero.centavos((pesos * 100).round());
}

/// Agrega comas cada tres dígitos: 1240 → `1,240`.
String _separarMiles(int numero) {
  final digitos = numero.toString();
  final grupos = <String>[];

  // Corta grupos de tres dígitos empezando desde el final.
  for (var fin = digitos.length; fin > 0; fin -= 3) {
    final inicio = max(0, fin - 3);
    grupos.insert(0, digitos.substring(inicio, fin));
  }
  return grupos.join(',');
}
