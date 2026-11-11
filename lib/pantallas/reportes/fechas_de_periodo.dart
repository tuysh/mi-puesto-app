import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/nucleo/fechas.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';

/// El nombre del periodo que contiene a [fecha], para mostrarlo entre las
/// flechas: "Hoy, jueves 6 de noviembre", "Lunes 3 al domingo 9 de
/// noviembre" o "Noviembre de 2026".
String textoDePeriodo(Periodo periodo, DateTime fecha) {
  return switch (periodo) {
    Periodo.dia => formatearFechaConHoy(fecha),
    Periodo.semana => formatearRango(lunesDe(fecha), domingoDe(fecha)),
    Periodo.mes => formatearMes(fecha),
  };
}

/// Un día del periodo anterior ([pasos] = -1) o del siguiente (+1) al que
/// contiene a [fecha].
DateTime moverDePeriodo(Periodo periodo, DateTime fecha, int pasos) {
  return switch (periodo) {
    Periodo.dia => sumarDias(fecha, pasos),
    Periodo.semana => sumarDias(fecha, 7 * pasos),
    Periodo.mes => sumarMeses(fecha, pasos),
  };
}

/// `true` si el periodo que contiene a [fecha] es el de hoy: el día de
/// hoy, esta semana o este mes. Después de ese ya no hay nada que mirar.
bool esElPeriodoActual(Periodo periodo, DateTime fecha) {
  final ahora = hoy();
  return switch (periodo) {
    Periodo.dia => esElMismoDia(fecha, ahora),
    Periodo.semana => esElMismoDia(lunesDe(fecha), lunesDe(ahora)),
    Periodo.mes => fecha.year == ahora.year && fecha.month == ahora.month,
  };
}
