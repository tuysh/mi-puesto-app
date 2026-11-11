import 'package:mi_puesto/nucleo/fechas.dart';

const _diasDeLaSemana = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Convierte una fecha a texto: `Jueves 6 de noviembre`.
String formatearFechaLarga(DateTime fecha) {
  return '${_nombreDelDia(fecha)} ${fecha.day} de ${_nombreDelMes(fecha)}';
}

/// Igual que [formatearFechaLarga], pero si la fecha es hoy lo dice:
/// `Hoy, jueves 6 de noviembre`.
String formatearFechaConHoy(DateTime fecha) {
  final texto = formatearFechaLarga(fecha);
  if (!esElMismoDia(fecha, DateTime.now())) return texto;

  return 'Hoy, ${_enMinuscula(texto)}';
}

/// Un día en corto, para las listas: `Sáb 8`.
String formatearDiaCorto(DateTime fecha) {
  return '${_nombreDelDia(fecha).substring(0, 3)} ${fecha.day}';
}

/// Un día sin el mes, para las tablas del reporte: `Lunes 3`.
String formatearDiaSinMes(DateTime fecha) {
  return '${_nombreDelDia(fecha)} ${fecha.day}';
}

/// Un rango de días: `Lunes 3 al domingo 9 de noviembre`. Si los dos días
/// son de meses distintos, cada uno lleva el suyo.
String formatearRango(DateTime desde, DateTime hasta) {
  final inicio = desde.month == hasta.month
      ? formatearDiaSinMes(desde)
      : formatearFechaLarga(desde);
  return '$inicio al ${_enMinuscula(formatearFechaLarga(hasta))}';
}

/// Un mes con su año: `Noviembre de 2026`.
String formatearMes(DateTime fecha) {
  final mes = _nombreDelMes(fecha);
  return '${mes[0].toUpperCase()}${mes.substring(1)} de ${fecha.year}';
}

/// La hora del día, como se dice en México: `2:14 p. m.`.
String formatearHora(DateTime momento) {
  final esDeLaTarde = momento.hour >= 12;
  // El reloj de 12 horas no tiene hora 0: las 0 y las 12 se dicen "12".
  final horaDeReloj = momento.hour % 12 == 0 ? 12 : momento.hour % 12;
  final minutos = momento.minute.toString().padLeft(2, '0');
  return '$horaDeReloj:$minutos ${esDeLaTarde ? 'p. m.' : 'a. m.'}';
}

/// Cuándo pasó algo, para decirlo en una frase: `hoy a las 2:20 p. m.` o
/// `el jueves 6 de noviembre a las 2:20 p. m.`.
String formatearCuando(DateTime momento) {
  final hora = formatearHora(momento);
  if (esElMismoDia(momento, DateTime.now())) return 'hoy a las $hora';

  return 'el ${_enMinuscula(formatearFechaLarga(momento))} a las $hora';
}

String _nombreDelDia(DateTime fecha) {
  // En DateTime el lunes es 1; la lista empieza en 0.
  return _diasDeLaSemana[fecha.weekday - 1];
}

String _nombreDelMes(DateTime fecha) => _meses[fecha.month - 1];

/// "Jueves 6" → "jueves 6": para cuando el día va en medio de una frase.
String _enMinuscula(String texto) {
  return '${texto[0].toLowerCase()}${texto.substring(1)}';
}
