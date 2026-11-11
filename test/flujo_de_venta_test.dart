import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/pantallas/vender/widgets/boton_de_quitar_pieza.dart';
import 'package:mi_puesto/pantallas/vender/widgets/insignia_de_cantidad.dart';

import 'ayudas.dart';

/// Recorre el camino de una venta con los datos simulados: quién vende →
/// PIN → vender → cobrar → venta registrada.
void main() {
  testWidgets('se puede registrar una venta y ver el cambio', (tester) async {
    await abrirAplicacion(tester);
    expect(find.text('¿Quién vende hoy?'), findsOneWidget);
    expect(find.text('Puesto Doña Mari'), findsOneWidget);
    await entrarComo(tester, 'Mari', '1234');

    // Vender: dos pays de limón ($45) y un esquite ($35).
    await tester.tap(find.text('Pay limón'));
    await tester.tap(find.text('Pay limón'));
    await tester.tap(find.text('Esquite'));
    await esperarRespuesta(tester);
    expect(find.text('3 productos · ver'), findsOneWidget);
    expect(find.text('\$125'), findsOneWidget);

    // Cobrar: paga con $200.
    await tester.tap(find.text('Cobrar'));
    await esperarRespuesta(tester);
    expect(find.text('2 × Pay limón'), findsOneWidget);
    expect(find.text('Registrar exacto \$125'), findsOneWidget);
    await tester.tap(find.text('\$200'));
    await esperarRespuesta(tester);
    expect(find.text('\$75'), findsOneWidget);
    await tester.tap(find.text('Registrar \$125'));
    await esperarRespuesta(tester);

    // De vuelta en Vender, con el aviso y el pedido vacío.
    expect(
      find.text('Venta registrada · efectivo, pagó \$200'),
      findsOneWidget,
    );
    expect(find.text('\$75'), findsOneWidget);
    expect(find.text('3 productos · ver'), findsNothing);

    // La dueña puede abrir la venta para corregirla.
    await tester.tap(find.text('Ver o corregir esta venta'));
    await esperarRespuesta(tester);
    expect(find.text('Editar venta'), findsOneWidget);
    expect(find.text('Cancelar venta'), findsOneWidget);
  });

  testWidgets('con tarjeta no hay billetes ni cambio', (tester) async {
    await abrirComoDuena(tester);

    await tester.tap(find.text('Flan'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Cobrar'));
    await esperarRespuesta(tester);

    await tester.tap(find.text('Tarjeta'));
    await esperarRespuesta(tester);
    expect(find.text('\$200'), findsNothing);
    await tester.tap(find.text('Registrar con tarjeta \$35'));
    await esperarRespuesta(tester);

    expect(find.text('Venta registrada · tarjeta'), findsOneWidget);
  });

  testWidgets('un producto con tamaños pide elegir cuál', (tester) async {
    await abrirComoDuena(tester);

    expect(find.text('desde \$15'), findsWidgets);
    await tester.ensureVisible(find.text('Horchata'));
    await tester.tap(find.text('Horchata'));
    await esperarRespuesta(tester);
    expect(find.text('¿De qué tamaño?'), findsOneWidget);
    expect(find.text('Elige al menos uno'), findsOneWidget);

    // Dos chicas ($15) y una grande ($25).
    await tester.tap(find.bySemanticsLabel('Agregar un Horchata chica'));
    await tester.tap(find.bySemanticsLabel('Agregar un Horchata chica'));
    await tester.tap(find.bySemanticsLabel('Agregar un Horchata grande'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Agregar 3 · \$55'));
    await esperarRespuesta(tester);

    // Cada tamaño es su propio renglón, pero la tesela suma los dos.
    expect(find.text('3 en cuenta'), findsOneWidget);
    expect(find.text('3 productos · ver'), findsOneWidget);
    final pedido = dependenciasDe(tester).pedido;
    expect(pedido.lineas.length, 2);
    expect(pedido.lineas.first.nombreCompleto, 'Horchata chica');

    // La pantalla "Pedido" muestra un renglón por tamaño.
    await tester.tap(find.text('3 productos · ver'));
    await esperarRespuesta(tester);
    expect(find.text('Chica · \$15 c/u'), findsOneWidget);
    expect(find.text('Grande · \$25 c/u'), findsOneWidget);
    expect(find.text('Cobrar \$55'), findsOneWidget);
  });

  testWidgets('lo que hoy no hay se ve, pero no se puede agregar', (
    tester,
  ) async {
    await abrirComoDuena(tester);

    expect(find.text('Hoy no hay'), findsOneWidget);
    await tester.ensureVisible(find.text('Mango'));
    await tester.tap(find.text('Mango'), warnIfMissed: false);
    await esperarRespuesta(tester);

    expect(dependenciasDe(tester).pedido.estaVacio, isTrue);
  });

  testWidgets('el "−" de un producto quita una pieza del pedido', (
    tester,
  ) async {
    await abrirComoDuena(tester);

    // Sin piezas en el pedido, el producto no tiene "−" e invita a tocar.
    expect(find.byType(BotonDeQuitarPieza), findsNothing);
    expect(find.text('Toca para agregar'), findsWidgets);

    await tester.tap(find.text('Flan'));
    await tester.tap(find.text('Flan'));
    await esperarRespuesta(tester);
    expect(find.text('2 productos · ver'), findsOneWidget);
    expect(find.text('2 en cuenta'), findsOneWidget);

    await tester.tap(find.byType(BotonDeQuitarPieza));
    await esperarRespuesta(tester);
    expect(find.text('1 producto · ver'), findsOneWidget);
    expect(find.text('1 en cuenta'), findsOneWidget);

    // Al quitar la última pieza, el "−" desaparece con ella.
    await tester.tap(find.byType(BotonDeQuitarPieza));
    await esperarRespuesta(tester);
    expect(find.byType(BotonDeQuitarPieza), findsNothing);
    expect(find.text('1 producto · ver'), findsNothing);
  });

  testWidgets('en tablet la tesela marca cuántas piezas lleva el pedido', (
    tester,
  ) async {
    await abrirComoDuena(tester, enTablet: true);

    expect(find.byType(InsigniaDeCantidad), findsNothing);

    await tester.tap(find.text('Flan'));
    await tester.tap(find.text('Flan'));
    await esperarRespuesta(tester);

    // La insignia sale en la tesela; el "−" está en el pedido de la derecha,
    // no en la tesela.
    expect(find.byType(InsigniaDeCantidad), findsOneWidget);
    expect(find.byType(BotonDeQuitarPieza), findsNothing);
    expect(find.text('Registrar exacto \$70'), findsOneWidget);

    // En tablet se cobra ahí mismo, sin cambiar de pantalla.
    await tester.tap(find.text('Registrar exacto \$70'));
    await esperarRespuesta(tester);
    expect(find.text('Venta registrada · efectivo, pagó \$70'), findsOneWidget);
  });

  testWidgets('quien solo vende ve dos pestañas y nada más sus ventas', (
    tester,
  ) async {
    await abrirAplicacion(tester);
    await entrarComo(tester, 'Lupe', '1111');

    expect(find.text('Mis ventas'), findsOneWidget);
    expect(find.text('Hoy'), findsNothing);
    expect(find.text('Reportes'), findsNothing);
    expect(find.text('Más'), findsNothing);

    await tester.tap(find.text('Flan'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Cobrar'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Registrar exacto \$35'));
    await esperarRespuesta(tester);

    // Quien solo vende no puede corregir: el aviso no lleva ese botón.
    expect(find.text('Ver o corregir esta venta'), findsNothing);

    await tester.tap(find.text('Mis ventas'));
    await esperarRespuesta(tester);
    expect(find.text('1 venta que registraste hoy'), findsOneWidget);
    expect(find.text('1 flan'), findsOneWidget);
  });
}
