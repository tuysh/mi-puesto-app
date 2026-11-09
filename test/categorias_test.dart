import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/app/mi_puesto_app.dart';

import 'flujo_de_venta_test.dart';

void main() {
  testWidgets('se puede agregar una categoría nueva', (tester) async {
    await abrirCategorias(tester);
    expect(find.text('Postres'), findsOneWidget);

    // Crear "Helados".
    await tester.tap(find.text('Nueva categoría'));
    await esperarRespuesta(tester);
    await tester.enterText(find.byType(TextField), 'Helados');
    await tester.tap(find.text('Guardar categoría'));
    await esperarRespuesta(tester);

    // Aparece en la lista, todavía sin productos…
    expect(find.text('Helados'), findsOneWidget);
    expect(find.text('0 productos'), findsOneWidget);

    // …y en el filtro de la pantalla Vender.
    await tester.tap(find.byTooltip('Volver'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Vender'));
    await esperarRespuesta(tester);
    expect(find.text('🍽️ Helados'), findsOneWidget);
  });

  testWidgets('se puede eliminar una categoría sin productos', (tester) async {
    await abrirCategorias(tester);

    // Crear "Helados" y volver a abrirla.
    await tester.tap(find.text('Nueva categoría'));
    await esperarRespuesta(tester);
    await tester.enterText(find.byType(TextField), 'Helados');
    await tester.tap(find.text('Guardar categoría'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Helados'));
    await esperarRespuesta(tester);

    // Eliminarla, confirmando en el diálogo.
    await tester.tap(find.text('Eliminar categoría'));
    await esperarRespuesta(tester);
    expect(find.text('¿Eliminar Helados?'), findsOneWidget);
    await tester.tap(find.text('Eliminar'));
    await esperarRespuesta(tester);

    expect(find.text('Helados'), findsNothing);
    expect(find.text('Postres'), findsOneWidget);
  });

  testWidgets('una categoría con productos no se elimina', (tester) async {
    await abrirCategorias(tester);

    await tester.tap(find.text('Postres'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Eliminar categoría'));
    await esperarRespuesta(tester);

    // No pregunta nada: solo explica por qué no se puede.
    expect(find.text('¿Eliminar Postres?'), findsNothing);
    expect(find.textContaining('Pásalos a otra categoría'), findsOneWidget);
  });
}

/// Entra a la aplicación y llega a Productos › Categorías.
Future<void> abrirCategorias(WidgetTester tester) async {
  usarPantallaDeTelefono(tester);
  await tester.pumpWidget(const MiPuestoApp());
  await esperarRespuesta(tester);

  for (final digito in ['1', '2', '3', '4']) {
    await tester.tap(find.text(digito));
  }
  await esperarRespuesta(tester);
  await tester.tap(find.text('Entrar'));
  await esperarRespuesta(tester);
  await tester.tap(find.text('Mari'));
  await esperarRespuesta(tester);
  await tester.tap(find.text('Más'));
  await esperarRespuesta(tester);
  await tester.tap(find.text('Productos'));
  await esperarRespuesta(tester);
  await tester.tap(find.text('Categorías'));
  await esperarRespuesta(tester);
}
