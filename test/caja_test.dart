import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/datos/conexiones.dart';

import 'ayudas.dart';

/// Abrir y cerrar la caja, con los datos simulados. Sin caja abierta nadie
/// puede vender.
void main() {
  Conexiones conLaCajaCerrada() {
    return Conexiones.simuladas(conSesionIniciada: true, conCajaAbierta: false);
  }

  testWidgets('sin caja, quien solo vende tiene que pedir que la abran', (
    tester,
  ) async {
    await abrirAplicacion(tester, conexiones: conLaCajaCerrada());
    await entrarComo(tester, 'Lupe', '1111');

    expect(find.text('Todavía no se abre la caja'), findsOneWidget);
    expect(find.textContaining('pídele a Mari'), findsOneWidget);
    expect(find.text('Flan'), findsNothing);

    await tester.tap(find.text('Cambiar de persona'));
    await esperarRespuesta(tester);
    expect(find.text('¿Quién vende hoy?'), findsOneWidget);
  });

  testWidgets('la dueña abre la caja y ya se puede vender', (tester) async {
    await abrirAplicacion(tester, conexiones: conLaCajaCerrada());
    await entrarComo(tester, 'Mari', '1234');

    expect(find.text('Abre la caja para empezar'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '300');
    await tester.tap(find.text('Abrir caja'));
    await esperarRespuesta(tester);

    expect(find.text('Flan'), findsOneWidget);
    expect(dependenciasDe(tester).caja.estaAbierta, isTrue);

    // "Hoy" dice con cuánto se abrió.
    await tester.tap(find.text('Hoy'));
    await esperarRespuesta(tester);
    expect(find.text('Caja abierta · abriste con \$300'), findsOneWidget);
  });

  testWidgets('cerrar la caja compara lo contado con lo que debe haber', (
    tester,
  ) async {
    await abrirComoDuena(tester);

    // Una venta en efectivo de $35 y otra con tarjeta de $45.
    await tester.tap(find.text('Flan'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Cobrar'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Registrar exacto \$35'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Pay limón'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Cobrar'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Tarjeta'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Registrar con tarjeta \$45'));
    await esperarRespuesta(tester);

    await tester.tap(find.text('Hoy'));
    await esperarRespuesta(tester);
    expect(find.text('Vendido hoy · 2 ventas'), findsOneWidget);
    await tester.tap(find.text('Cerrar caja'));
    await esperarRespuesta(tester);

    // La caja de ejemplo abre con $500 y tiene un gasto de $420 pagado de
    // la caja: 500 + 35 − 420 = 115. La tarjeta no entra.
    expect(find.text('\$115'), findsOneWidget);
    expect(
      find.text('Lo vendido con tarjeta (\$45) no entra a la caja.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField).first, '110');
    await tester.pump();
    expect(find.text('Falta dinero'), findsOneWidget);
    expect(find.text('\$5'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '115');
    await tester.pump();
    expect(find.text('La caja cuadra'), findsOneWidget);

    // Cerrar es definitivo: se pregunta antes.
    await tocarBotonPrincipal(tester, 'Cerrar caja de hoy');
    expect(find.text('¿Cerrar la caja?'), findsOneWidget);
    await tocarBotonPrincipal(tester, 'Cerrar caja');

    // Se abre el resumen del cierre.
    expect(find.text('Caja cerrada'), findsOneWidget);
    expect(find.text('Vendido · 2 ventas'), findsOneWidget);
    expect(find.text('Debía haber'), findsOneWidget);
    expect(dependenciasDe(tester).caja.estaAbierta, isFalse);

    // De vuelta en "Hoy" ya no se ofrece cerrar.
    await tester.tap(find.byTooltip('Volver'));
    await esperarRespuesta(tester);
    expect(
      find.text('La caja está cerrada · ábrela en Vender'),
      findsOneWidget,
    );
    expect(find.text('Cerrar caja'), findsNothing);

    // Y el cierre queda en "Cierres anteriores".
    await abrirDesdeMas(tester, 'Cierres anteriores');
    expect(find.text('Cuadró'), findsOneWidget);
    expect(find.text('\$80'), findsOneWidget);
  });
}
