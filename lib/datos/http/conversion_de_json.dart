/// Funciones para pasar los datos sueltos del servidor (JSON) a los de la
/// aplicación, y de regreso: dinero, ids, fechas.
library;

import 'package:mi_puesto/datos/modelos/dinero.dart';

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

/// Igual que [dineroDeJson], pero conserva el `null` (por ejemplo, el
/// cambio de una venta con tarjeta).
Dinero? dineroONadaDeJson(Object? valor) {
  return valor == null ? null : dineroDeJson(valor);
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

/// Igual que [idDeJson], pero conserva el `null` (por ejemplo, un producto
/// sin categoría).
String? idONadaDeJson(Object? valor) => valor?.toString();

/// Convierte un id de la aplicación al número que espera el servidor.
int idAJson(String id) => int.parse(id);

/// Lee un momento del servidor (viene en UTC) y lo pasa a la hora local.
DateTime momentoDeJson(Object? valor) {
  return DateTime.parse(valor.toString()).toLocal();
}

/// Igual que [momentoDeJson], pero conserva el `null`.
DateTime? momentoONadaDeJson(Object? valor) {
  return valor == null ? null : momentoDeJson(valor);
}

/// Lee un día suelto del servidor: `2026-11-09`.
DateTime diaDeJson(Object? valor) => DateTime.parse(valor.toString());

/// Escribe un día suelto como lo espera el servidor: `2026-11-09`.
String diaAJson(DateTime dia) {
  final mes = dia.month.toString().padLeft(2, '0');
  final numero = dia.day.toString().padLeft(2, '0');
  return '${dia.year}-$mes-$numero';
}
