import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/nucleo/fechas.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';

void main() {
  test('las fechas se escriben con el día de la semana', () {
    // El 5 de noviembre de 2026 es jueves.
    expect(formatearFechaLarga(DateTime(2026, 11, 5)), 'Jueves 5 de noviembre');
    expect(formatearDiaCorto(DateTime(2026, 11, 7)), 'Sáb 7');
    expect(formatearMes(DateTime(2026, 11, 5)), 'Noviembre de 2026');
  });

  test('un rango dentro del mismo mes no repite el mes', () {
    expect(
      formatearRango(DateTime(2026, 11, 2), DateTime(2026, 11, 8)),
      'Lunes 2 al domingo 8 de noviembre',
    );
    expect(
      formatearRango(DateTime(2026, 10, 26), DateTime(2026, 11, 1)),
      'Lunes 26 de octubre al domingo 1 de noviembre',
    );
  });

  test('la hora va en reloj de 12 horas', () {
    expect(formatearHora(DateTime(2026, 11, 5, 14, 14)), '2:14 p. m.');
    expect(formatearHora(DateTime(2026, 11, 5, 9, 5)), '9:05 a. m.');
    expect(formatearHora(DateTime(2026, 11, 5, 0, 30)), '12:30 a. m.');
    expect(formatearHora(DateTime(2026, 11, 5, 12)), '12:00 p. m.');
  });

  test('la semana va de lunes a domingo', () {
    final jueves = DateTime(2026, 11, 5);

    expect(lunesDe(jueves), DateTime(2026, 11, 2));
    expect(domingoDe(jueves), DateTime(2026, 11, 8));
    // El lunes es su propio lunes, y el domingo no se pasa a otra semana.
    expect(lunesDe(DateTime(2026, 11, 2)), DateTime(2026, 11, 2));
    expect(lunesDe(DateTime(2026, 11, 8)), DateTime(2026, 11, 2));
  });

  test('sumar meses no se sale del mes que toca', () {
    expect(sumarMeses(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
    expect(sumarMeses(DateTime(2026, 1, 15), -1), DateTime(2025, 12, 15));
    expect(ultimoDiaDelMesDe(DateTime(2026, 2, 10)), DateTime(2026, 2, 28));
  });
}
