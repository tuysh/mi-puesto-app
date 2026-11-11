/// Cuentas sencillas con días: la semana va de lunes a domingo.
library;

/// [momento] sin la hora: solo el año, el mes y el día.
DateTime soloElDia(DateTime momento) {
  return DateTime(momento.year, momento.month, momento.day);
}

/// El día de hoy, sin la hora.
DateTime hoy() => soloElDia(DateTime.now());

bool esElMismoDia(DateTime uno, DateTime otro) {
  return uno.year == otro.year &&
      uno.month == otro.month &&
      uno.day == otro.day;
}

/// El día que está [dias] después de [dia] (o antes, si es negativo).
///
/// Se arma con el constructor en vez de sumar 24 horas, porque los días en
/// que cambia el horario no duran 24 horas.
DateTime sumarDias(DateTime dia, int dias) {
  return DateTime(dia.year, dia.month, dia.day + dias);
}

/// El lunes de la semana de [dia].
DateTime lunesDe(DateTime dia) {
  // En DateTime el lunes es 1 y el domingo es 7.
  return sumarDias(dia, 1 - dia.weekday);
}

/// El domingo de la semana de [dia].
DateTime domingoDe(DateTime dia) => sumarDias(lunesDe(dia), 6);

/// El día 1 del mes de [dia].
DateTime primerDiaDelMesDe(DateTime dia) => DateTime(dia.year, dia.month);

/// El último día del mes de [dia]. El "día 0" del mes siguiente es el
/// último de este.
DateTime ultimoDiaDelMesDe(DateTime dia) {
  return DateTime(dia.year, dia.month + 1, 0);
}

/// El mismo día del mes que está [meses] después (o antes). Si ese mes es
/// más corto (del 31 de enero a febrero), se queda en su último día.
DateTime sumarMeses(DateTime dia, int meses) {
  final ultimoDelMesNuevo = DateTime(dia.year, dia.month + meses + 1, 0);
  final numeroDeDia = dia.day < ultimoDelMesNuevo.day
      ? dia.day
      : ultimoDelMesNuevo.day;
  return DateTime(ultimoDelMesNuevo.year, ultimoDelMesNuevo.month, numeroDeDia);
}

/// `true` si [dia] está entre [desde] y [hasta], contando los dos.
bool estaEntre(DateTime dia, DateTime desde, DateTime hasta) {
  final elDia = soloElDia(dia);
  return !elDia.isBefore(soloElDia(desde)) && !elDia.isAfter(soloElDia(hasta));
}
