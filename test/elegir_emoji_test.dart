import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/app/mi_puesto_app.dart';
import 'package:mi_puesto/pantallas/productos/widgets/boton_de_emoji.dart';

import 'flujo_de_venta_test.dart';

/// El emoji de un producto se elige tocando, nunca escribiendo.
void main() {
  testWidgets('se puede cambiar el emoji de un producto', (tester) async {
    usarPantallaDeTelefono(tester);
    await tester.pumpWidget(const MiPuestoApp());
    await esperarRespuesta(tester);

    // Entrar y llegar a Productos.
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

    // Abrir el selector desde el formulario del flan.
    await tester.tap(find.text('Flan napolitano'));
    await esperarRespuesta(tester);
    await tester.tap(find.byType(BotonDeEmoji));
    await esperarRespuesta(tester);
    expect(find.text('Elige un emoji'), findsOneWidget);

    // El selector no tiene dónde escribir: los únicos campos de texto en
    // pantalla son los del formulario que quedó detrás.
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextField),
      ),
      findsNothing,
    );

    // Elegir una piña del grupo Frutas.
    await tester.tap(find.text('Frutas'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('🍍'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Usar este emoji'));
    await esperarRespuesta(tester);

    final boton = tester.widget<BotonDeEmoji>(find.byType(BotonDeEmoji));
    expect(boton.emoji, '🍍');
  });
}
