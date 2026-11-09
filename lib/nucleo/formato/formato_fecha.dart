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
  // En DateTime el lunes es 1 y enero es 1; las listas empiezan en 0.
  final dia = _diasDeLaSemana[fecha.weekday - 1];
  final mes = _meses[fecha.month - 1];
  return '$dia ${fecha.day} de $mes';
}
