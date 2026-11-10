import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';

void main() {
  testWidgets('si la carga falla explica por qué y se puede reintentar', (
    tester,
  ) async {
    var intentos = 0;
    Future<String> cargar() async {
      intentos++;
      if (intentos == 1) throw const ErrorDelServidor('Sin conexión.');
      return 'Listo';
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CargadorDeFuturo<String>(
            cargar: cargar,
            construir: (context, texto) => Text(texto),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión.'), findsOneWidget);

    await tester.tap(find.text('Intentar otra vez'));
    await tester.pumpAndSettle();
    expect(find.text('Listo'), findsOneWidget);
    expect(intentos, 2);
  });
}
