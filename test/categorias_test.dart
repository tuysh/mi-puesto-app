import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas.dart';

/// La pantalla "Categorías": las de productos y las de gastos, con los
/// datos simulados.
void main() {
  testWidgets('se puede agregar una categoría de productos', (tester) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Categorías');

    expect(find.text('Postres'), findsOneWidget);
    expect(find.text('5 productos'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Helados');
    await tester.tap(find.text('Agregar'));
    await esperarRespuesta(tester);

    expect(find.text('Helados'), findsOneWidget);
    expect(find.text('0 productos'), findsOneWidget);
    // "Vender" se entera: la categoría nueva ya está en el catálogo.
    final categorias = dependenciasDe(tester).catalogo.categorias;
    expect(categorias.last.nombre, 'Helados');
  });

  testWidgets('no puede haber dos categorías con el mismo nombre', (
    tester,
  ) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Categorías');

    await tester.enterText(find.byType(TextField), 'postres');
    await tester.tap(find.text('Agregar'));
    await esperarRespuesta(tester);

    expect(find.text('Ya hay una categoría con ese nombre.'), findsOneWidget);
  });

  testWidgets('al eliminar una categoría sus productos quedan sin ella', (
    tester,
  ) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Categorías');

    await tester.tap(find.byTooltip('Eliminar Dulces'));
    await esperarRespuesta(tester);
    expect(find.text('¿Eliminar Dulces?'), findsOneWidget);
    await tocarBotonPrincipal(tester, 'Eliminar');

    expect(find.text('Dulces'), findsNothing);
    final catalogo = dependenciasDe(tester).catalogo;
    final paleta = catalogo.productos.firstWhere((p) => p.nombre == 'Paleta');
    expect(paleta.categoriaId, isNull);
  });

  testWidgets('las categorías de gastos van en su propia pestaña', (
    tester,
  ) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Categorías');

    await tester.tap(find.text('De gastos'));
    await esperarRespuesta(tester);
    expect(find.text('Ingredientes'), findsOneWidget);
    expect(find.text('Postres'), findsNothing);
    // Los dos gastos de ejemplo: uno de Ingredientes y uno de Plaza.
    expect(find.text('1 gasto'), findsNWidgets(2));

    // Renombrar "Gas" a "Gas y luz".
    await tester.tap(find.byTooltip('Cambiar nombre de Gas'));
    await esperarRespuesta(tester);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Gas y luz',
    );
    await tocarBotonPrincipal(tester, 'Aceptar');

    expect(find.text('Gas y luz'), findsOneWidget);
    expect(find.text('Gas'), findsNothing);
  });
}
