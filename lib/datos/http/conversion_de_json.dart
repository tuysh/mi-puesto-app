/// Funciones para pasar los datos del servidor (JSON) a los modelos de la
/// aplicación, y de regreso.
library;

import 'dart:ui';

import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Lee dinero del servidor, que lo manda como texto: `"45.00"`.
///
/// Se separan pesos y centavos a mano, sin pasar por decimales, para que
/// la cantidad sea exacta. `null` se toma como cero.
Dinero dineroDeJson(Object? valor) {
  if (valor == null) return Dinero.cero;

  var texto = valor.toString().trim();
  final esNegativo = texto.startsWith('-');
  if (esNegativo) texto = texto.substring(1);

  final partes = texto.split('.');
  final pesos = int.parse(partes[0].isEmpty ? '0' : partes[0]);
  // "5" son 50 centavos y "05" son 5: se completa a dos dígitos.
  final digitosDeCentavos = partes.length > 1 ? partes[1] : '';
  final centavos = int.parse(
    digitosDeCentavos.padRight(2, '0').substring(0, 2),
  );

  final total = pesos * 100 + centavos;
  return Dinero.centavos(esNegativo ? -total : total);
}

/// Escribe dinero como lo espera el servidor: `"45.00"`.
String dineroAJson(Dinero monto) {
  final signo = monto.esNegativo ? '-' : '';
  final centavos = monto.centavos.abs();
  final pesos = centavos ~/ 100;
  final resto = (centavos % 100).toString().padLeft(2, '0');
  return '$signo$pesos.$resto';
}

/// Los ids del servidor son números; en la aplicación son texto.
String idDeJson(Object? valor) => valor.toString();

/// Convierte un id de la aplicación al número que espera el servidor.
int idAJson(String id) => int.parse(id);

/// Lee un momento del servidor (viene en UTC) y lo pasa a la hora local.
DateTime momentoDeJson(Object? valor) {
  return DateTime.parse(valor.toString()).toLocal();
}

/// Escribe un día suelto como lo espera el servidor: `2026-11-09`.
String diaAJson(DateTime dia) {
  final mes = dia.month.toString().padLeft(2, '0');
  final numero = dia.day.toString().padLeft(2, '0');
  return '${dia.year}-$mes-$numero';
}

/// Arma el par de colores de una categoría a partir de `#RRGGBB`.
///
/// Si coincide con uno de los [Pasteles] devuelve ese mismo objeto, para
/// que el selector de color del formulario lo reconozca como elegido.
ParDeColores coloresDeJson(Object? fondo, Object? tinta) {
  final colorDeFondo = _colorDeJson(fondo);
  final colorDeTinta = _colorDeJson(tinta);
  if (colorDeFondo == null || colorDeTinta == null) return Pasteles.rosa;

  for (final pastel in Pasteles.todos) {
    if (pastel.fondo.toARGB32() == colorDeFondo.toARGB32() &&
        pastel.tinta.toARGB32() == colorDeTinta.toARGB32()) {
      return pastel;
    }
  }
  return ParDeColores(fondo: colorDeFondo, tinta: colorDeTinta);
}

/// Escribe un color como lo espera el servidor: `#F9D3DE`.
String colorAJson(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

Color? _colorDeJson(Object? valor) {
  final texto = valor?.toString().replaceFirst('#', '') ?? '';
  final rgb = texto.length == 6 ? int.tryParse(texto, radix: 16) : null;
  if (rgb == null) return null;

  return Color(0xFF000000 | rgb);
}
