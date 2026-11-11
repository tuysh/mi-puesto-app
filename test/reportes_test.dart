import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

/// La pantalla "Reportes", con los datos simulados.
void main() {
  testWidgets('cabe en un teléfono angosto, sin desbordarse', (tester) async {
    await abrirComoDuena(tester);
    // Más angosto que el teléfono del diseño (390). Si algo no cabe,
    // Flutter lanza un error de "overflow" y la prueba falla.
    tester.view.physicalSize = const Size(340, 740);
    await tester.pump();

    await tester.tap(find.text('Reportes'));
    await esperarRespuesta(tester);

    expect(find.text('Lo más vendido'), findsOneWidget);
    expect(find.text('Piezas'), findsOneWidget);
    expect(find.text('Dinero'), findsOneWidget);
  });

  testWidgets('"Lo más vendido" se puede ordenar por dinero', (tester) async {
    await abrirComoDuena(tester);
    // Se vende un flan ($35) para que haya algo que reportar.
    await tester.tap(find.text('Flan'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Cobrar'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Registrar exacto \$35'));
    await esperarRespuesta(tester);

    await tester.tap(find.text('Reportes'));
    await esperarRespuesta(tester);
    expect(find.text('1 pzs'), findsOneWidget);

    await tester.tap(find.text('Dinero'));
    await esperarRespuesta(tester);
    expect(find.text('1 pzs'), findsNothing);
    expect(find.text('Vendido · 1 venta'), findsOneWidget);
  });
}
