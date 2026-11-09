import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';

void main() {
  group('formatearDinero', () {
    test('muestra pesos enteros sin centavos', () {
      expect(formatearDinero(const Dinero.pesos(45)), '\$45');
    });

    test('separa los miles con comas', () {
      expect(formatearDinero(const Dinero.pesos(1240)), '\$1,240');
      expect(formatearDinero(const Dinero.pesos(1234567)), '\$1,234,567');
    });

    test('muestra los centavos solo cuando los hay', () {
      expect(formatearDinero(const Dinero.centavos(1250)), '\$12.50');
      expect(formatearDinero(const Dinero.centavos(1205)), '\$12.05');
    });

    test('pone el signo menos antes del signo de pesos', () {
      expect(formatearDinero(const Dinero.pesos(-5)), '-\$5');
    });
  });

  group('leerDinero', () {
    test('acepta números con comas y signo de pesos', () {
      expect(leerDinero('1735'), const Dinero.pesos(1735));
      expect(leerDinero('1,735'), const Dinero.pesos(1735));
      expect(leerDinero('\$12.50'), const Dinero.centavos(1250));
    });

    test('devuelve null si el texto no es una cantidad', () {
      expect(leerDinero(''), isNull);
      expect(leerDinero('abc'), isNull);
      expect(leerDinero('-5'), isNull);
    });
  });
}
