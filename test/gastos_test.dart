import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

/// Anotar, cambiar y eliminar gastos, con los datos simulados. El negocio
/// de ejemplo trae dos gastos de hoy: $420 de la caja y $250 aparte.
void main() {
  testWidgets('se puede anotar un gasto pagado de la caja', (tester) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Gastos');

    expect(find.text('2 gastos'), findsOneWidget);
    expect(find.text('\$670'), findsOneWidget);

    await tocarBotonPrincipal(tester, 'Anotar gasto');
    expect(find.text('¿Cuánto se gastó?'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), '180');
    await tester.enterText(find.byType(TextField).at(1), 'Tanque de gas');
    await tester.tap(find.text('Gas'));
    await tester.pump();
    // Con la caja abierta, lo normal es que salga de ahí.
    expect(
      find.text('Se descuenta de lo que debe haber al cerrar caja.'),
      findsOneWidget,
    );
    await tocarBotonPrincipal(tester, 'Guardar gasto');

    // De vuelta en la lista, ya con el gasto nuevo.
    expect(find.text('3 gastos'), findsOneWidget);
    expect(find.text('\$850'), findsOneWidget);
    expect(find.text('Tanque de gas'), findsOneWidget);
    expect(find.textContaining('Gas · de la caja'), findsOneWidget);

    // La caja lo descuenta: 500 − 420 − 180 = −100.
    // (Sin `await`: el reloj de la prueba solo avanza con `pump`.)
    final caja = dependenciasDe(tester).caja;
    caja.actualizar();
    await esperarRespuesta(tester);
    expect(caja.caja!.efectivoEsperado.centavos, -10000);
  });

  testWidgets('el filtro de categoría deja ver solo esos gastos', (
    tester,
  ) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Gastos');

    // El filtro se desliza hacia los lados: "Plaza" queda fuera de vista.
    await tester.ensureVisible(find.text('Plaza'));
    await tester.tap(find.text('Plaza'));
    await esperarRespuesta(tester);

    expect(find.text('1 gasto'), findsOneWidget);
    expect(find.text('Cuota de la semana'), findsOneWidget);
    expect(find.text('Fresas y crema'), findsNothing);
  });

  testWidgets('un gasto se puede eliminar', (tester) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Gastos');

    await tester.tap(find.text('Cuota de la semana'));
    await esperarRespuesta(tester);
    expect(find.text('Editar gasto'), findsOneWidget);

    await tester.tap(find.text('Eliminar'));
    await esperarRespuesta(tester);
    expect(find.text('¿Eliminar este gasto?'), findsOneWidget);
    await tocarBotonPrincipal(tester, 'Eliminar');

    expect(find.text('1 gasto'), findsOneWidget);
    expect(find.text('Cuota de la semana'), findsNothing);
  });
}
