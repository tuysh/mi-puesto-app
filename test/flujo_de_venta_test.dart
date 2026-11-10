import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/app/mi_puesto_app.dart';
import 'package:mi_puesto/datos/conexiones.dart';
import 'package:mi_puesto/pantallas/vender/widgets/boton_de_quitar_pieza.dart';

/// Recorre el camino completo de una venta en teléfono, con los datos
/// simulados: PIN → quién vende → vender → cobrar → venta registrada.
void main() {
  testWidgets('se puede registrar una venta y ver el cambio', (tester) async {
    usarPantallaDeTelefono(tester);
    await tester.pumpWidget(
      MiPuestoApp(conexiones: Conexiones.simuladas(conSesionIniciada: true)),
    );
    await esperarRespuesta(tester);
    expect(find.text('Puesto Doña Mari'), findsOneWidget);

    // 1. PIN
    for (final digito in ['1', '2', '3', '4']) {
      await tester.tap(find.text(digito));
    }
    await esperarRespuesta(tester);
    await tester.tap(find.text('Entrar'));
    await esperarRespuesta(tester);

    // 2. ¿Quién vende?
    expect(find.text('¿Quién vende hoy?'), findsOneWidget);
    await tester.tap(find.text('Mari'));
    await esperarRespuesta(tester);

    // 3. Vender: dos pays de limón ($45) y un esquite ($35).
    await tester.tap(find.text('Pay limón'));
    await tester.tap(find.text('Pay limón'));
    await tester.tap(find.text('Esquite'));
    await esperarRespuesta(tester);
    expect(find.text('3 productos · ver'), findsOneWidget);
    expect(find.text('\$125'), findsOneWidget);

    // 4. Cobrar: paga con $200.
    await tester.tap(find.text('Cobrar'));
    await esperarRespuesta(tester);
    expect(find.text('Registrar exacto \$125'), findsOneWidget);
    await tester.tap(find.text('\$200'));
    await esperarRespuesta(tester);
    expect(find.text('\$75'), findsOneWidget);
    await tester.tap(find.text('Registrar \$125'));
    await esperarRespuesta(tester);

    // 5. De vuelta en Vender, con el aviso y el pedido vacío.
    expect(find.text('Venta registrada · pagó \$200'), findsOneWidget);
    expect(find.text('\$75'), findsOneWidget);
    expect(find.text('Toca un producto para sumarlo'), findsOneWidget);

    // "Me equivoqué" devuelve los productos al pedido.
    await tester.tap(find.text('Me equivoqué: corregir pedido'));
    await esperarRespuesta(tester);
    expect(find.text('3 productos · ver'), findsOneWidget);
  });

  testWidgets('el "−" de un producto quita una pieza del pedido', (
    tester,
  ) async {
    usarPantallaDeTelefono(tester);
    await tester.pumpWidget(
      MiPuestoApp(conexiones: Conexiones.simuladas(conSesionIniciada: true)),
    );
    await esperarRespuesta(tester);
    for (final digito in ['1', '2', '3', '4']) {
      await tester.tap(find.text(digito));
    }
    await esperarRespuesta(tester);
    await tester.tap(find.text('Entrar'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Mari'));
    await esperarRespuesta(tester);

    // Sin piezas en el pedido, el producto no tiene "−".
    expect(find.byType(BotonDeQuitarPieza), findsNothing);

    await tester.tap(find.text('Flan'));
    await tester.tap(find.text('Flan'));
    await esperarRespuesta(tester);
    expect(find.text('2 productos · ver'), findsOneWidget);

    await tester.tap(find.byType(BotonDeQuitarPieza));
    await esperarRespuesta(tester);
    expect(find.text('1 producto · ver'), findsOneWidget);

    // Al quitar la última pieza, el "−" desaparece con ella.
    await tester.tap(find.byType(BotonDeQuitarPieza));
    await esperarRespuesta(tester);
    expect(find.byType(BotonDeQuitarPieza), findsNothing);
    expect(find.text('Toca un producto para sumarlo'), findsOneWidget);
  });

  testWidgets('un PIN incorrecto no deja entrar', (tester) async {
    usarPantallaDeTelefono(tester);
    await tester.pumpWidget(
      MiPuestoApp(conexiones: Conexiones.simuladas(conSesionIniciada: true)),
    );
    await esperarRespuesta(tester);

    for (final digito in ['9', '9', '9', '9']) {
      await tester.tap(find.text(digito));
    }
    await esperarRespuesta(tester);
    await tester.tap(find.text('Entrar'));
    await esperarRespuesta(tester);

    expect(find.text('PIN incorrecto. Intenta otra vez'), findsOneWidget);
    expect(find.text('¿Quién vende hoy?'), findsNothing);
  });
}

/// Hace que la prueba se dibuje del tamaño de un teléfono.
void usarPantallaDeTelefono(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Deja pasar el tiempo que tarda en "responder" el servidor simulado y
/// espera a que terminen las animaciones.
Future<void> esperarRespuesta(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
}
