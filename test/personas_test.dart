import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/nucleo/widgets/interruptor.dart';

import 'ayudas.dart';

/// Agregar, cambiar y desactivar personas, con los datos simulados.
void main() {
  /// En el diálogo "PIN nuevo": escribe [pin] y acepta.
  Future<void> escribirPinNuevo(WidgetTester tester, String pin) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      pin,
    );
    await tocarBotonPrincipal(tester, 'Aceptar');
  }

  testWidgets('se puede agregar a alguien que vende, con su PIN', (
    tester,
  ) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Personas');

    expect(find.text('Dueña · tú'), findsOneWidget);
    expect(find.text('Vende'), findsNWidgets(2));

    await tocarBotonPrincipal(tester, 'Agregar persona');
    await tester.enterText(find.byType(TextField), 'Chayo');
    await tester.pump();

    // Sin PIN no se puede guardar.
    await tocarBotonPrincipal(tester, 'Agregar persona');
    expect(find.text('Ponle un PIN de 4 números'), findsOneWidget);
    await esperarAQueSeQuiteElAviso(tester);

    await tester.tap(find.text('Poner PIN'));
    await esperarRespuesta(tester);
    await escribirPinNuevo(tester, '4321');
    await tocarBotonPrincipal(tester, 'Agregar persona');

    // De vuelta en la lista, y ya puede entrar con ese PIN.
    expect(find.text('Chayo'), findsOneWidget);
    await tester.tap(find.byTooltip('Volver'));
    await esperarRespuesta(tester);
    // Para cambiar de persona se toca a quien está dentro, en "Vender".
    await tester.tap(find.text('Vender'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Mari'));
    await esperarRespuesta(tester);
    expect(find.text('¿Quién vende hoy?'), findsOneWidget);
    await entrarComo(tester, 'Chayo', '4321');
    expect(dependenciasDe(tester).sesion.perfil?.nombre, 'Chayo');
  });

  testWidgets('un PIN que no son 4 números no se acepta', (tester) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Personas');
    await tester.tap(find.text('Lupe'));
    await esperarRespuesta(tester);

    await tester.tap(find.text('Cambiar PIN'));
    await esperarRespuesta(tester);
    await escribirPinNuevo(tester, '12');

    expect(find.text('El PIN son 4 números'), findsOneWidget);
  });

  testWidgets('una persona desactivada ya no sale en "¿Quién vende hoy?"', (
    tester,
  ) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Personas');
    await tester.tap(find.text('Toño'));
    await esperarRespuesta(tester);
    expect(find.text('Editar persona'), findsOneWidget);

    await tester.tap(find.byType(Interruptor));
    await esperarRespuesta(tester);
    await tocarBotonPrincipal(tester, 'Guardar cambios');

    // Sigue en la lista de personas, marcada como desactivada…
    expect(find.text('Desactivada'), findsOneWidget);
    // …pero ya no está entre quienes pueden entrar.
    final nombres = dependenciasDe(tester).sesion.perfiles.map((p) => p.nombre);
    expect(nombres, ['Mari', 'Lupe']);
  });

  testWidgets('a la dueña no se le puede desactivar', (tester) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Personas');
    await tester.tap(find.text('Dueña · tú'));
    await esperarRespuesta(tester);

    expect(find.text('Editar persona'), findsOneWidget);
    expect(find.byType(Interruptor), findsNothing);
  });
}
