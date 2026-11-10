import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/app/mi_puesto_app.dart';

import 'flujo_de_venta_test.dart';

/// Recorre las pantallas de cuenta con los datos simulados: iniciar
/// sesión, crear cuenta, crear el PIN y cerrar sesión.
void main() {
  testWidgets('sin sesión, la aplicación abre en "Inicia sesión"', (
    tester,
  ) async {
    await abrirAplicacion(tester);

    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.text('Escribe el PIN del puesto'), findsNothing);
  });

  testWidgets('con la cuenta de ejemplo se llega al PIN del puesto', (
    tester,
  ) async {
    await abrirAplicacion(tester);

    await escribirCuenta(tester, 'mari@ejemplo.com', 'pay-de-limon');
    await tester.tap(find.text('Entrar'));
    await esperarRespuesta(tester);

    expect(find.text('Puesto Doña Mari'), findsOneWidget);
    expect(find.text('Escribe el PIN del puesto'), findsOneWidget);
  });

  testWidgets('una contraseña incorrecta no deja entrar', (tester) async {
    await abrirAplicacion(tester);

    await escribirCuenta(tester, 'mari@ejemplo.com', 'otra-contraseña');
    await tester.tap(find.text('Entrar'));
    await esperarRespuesta(tester);

    expect(
      find.text('El correo o la contraseña no son correctos'),
      findsOneWidget,
    );
    expect(find.text('Inicia sesión'), findsOneWidget);
  });

  testWidgets('"Mostrar" deja ver la contraseña', (tester) async {
    await abrirAplicacion(tester);
    await escribirCuenta(tester, 'mari@ejemplo.com', 'pay-de-limon');

    bool contrasenaOculta() {
      return tester.widget<TextField>(find.byType(TextField).last).obscureText;
    }

    expect(contrasenaOculta(), isTrue);
    await tester.tap(find.text('Mostrar'));
    await tester.pump();
    expect(contrasenaOculta(), isFalse);
    expect(find.text('Ocultar'), findsOneWidget);
  });

  testWidgets('se puede crear una cuenta, su PIN y volver a entrar', (
    tester,
  ) async {
    await abrirAplicacion(tester);
    await tester.tap(find.text('Crear cuenta'));
    await esperarRespuesta(tester);
    expect(find.text('Crea tu cuenta'), findsOneWidget);

    // Una contraseña corta no pasa.
    await escribirCuenta(tester, 'lupe@ejemplo.com', 'corta');
    await tester.tap(find.text('Crear cuenta'));
    await esperarRespuesta(tester);
    expect(
      find.text('La contraseña necesita al menos 8 caracteres'),
      findsOneWidget,
    );
    expect(find.text('Crea tu cuenta'), findsOneWidget);
    // Deja que el aviso se quite solo, para que no tape los botones.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await escribirCuenta(tester, 'lupe@ejemplo.com', 'agua-de-jamaica');
    await tester.tap(find.text('Crear cuenta'));
    await esperarRespuesta(tester);

    // Paso 1: elegir el PIN.
    expect(find.text('Paso 1 de 2'), findsOneWidget);
    expect(find.text('Crea el PIN del puesto'), findsOneWidget);
    await escribirPin(tester, '2580');
    await tester.tap(find.text('Continuar'));
    await esperarRespuesta(tester);

    // Paso 2: si no coincide, hay que empezar de nuevo.
    expect(find.text('Repite el PIN'), findsOneWidget);
    await escribirPin(tester, '2581');
    expect(
      find.text('No es igual al primero. Empieza de nuevo.'),
      findsOneWidget,
    );
    expect(find.text('Guardar PIN'), findsNothing);
    await tester.tap(find.text('Empezar de nuevo'));
    await esperarRespuesta(tester);
    expect(find.text('Paso 1 de 2'), findsOneWidget);

    await escribirPin(tester, '2580');
    await tester.tap(find.text('Continuar'));
    await esperarRespuesta(tester);
    await escribirPin(tester, '2580');
    await tester.tap(find.text('Guardar PIN'));
    await esperarRespuesta(tester);

    // Después de crear el PIN se pasa directo a elegir quién vende.
    expect(find.text('¿Quién vende hoy?'), findsOneWidget);

    // Cerrar sesión pregunta antes y vuelve a "Inicia sesión".
    await tester.tap(find.text('Cerrar sesión'));
    await esperarRespuesta(tester);
    expect(find.text('¿Cerrar sesión?'), findsOneWidget);
    await tester.tap(find.text('Cerrar sesión').last);
    await esperarRespuesta(tester);
    expect(find.text('Inicia sesión'), findsOneWidget);

    // La cuenta nueva entra con su propio PIN.
    await escribirCuenta(tester, 'lupe@ejemplo.com', 'agua-de-jamaica');
    await tester.tap(find.text('Entrar'));
    await esperarRespuesta(tester);
    expect(find.text('Escribe el PIN del puesto'), findsOneWidget);
    await escribirPin(tester, '2580');
    await tester.tap(find.text('Entrar'));
    await esperarRespuesta(tester);
    expect(find.text('¿Quién vende hoy?'), findsOneWidget);
  });

  testWidgets('no se puede crear una cuenta con un correo ya usado', (
    tester,
  ) async {
    await abrirAplicacion(tester);
    await tester.tap(find.text('Crear cuenta'));
    await esperarRespuesta(tester);

    await escribirCuenta(tester, 'mari@ejemplo.com', 'pay-de-limon');
    await tester.tap(find.text('Crear cuenta'));
    await esperarRespuesta(tester);

    expect(find.text('Ya hay una cuenta con ese correo.'), findsOneWidget);
    expect(find.text('Crea tu cuenta'), findsOneWidget);
  });

  testWidgets('"Iniciar sesión" regresa desde crear cuenta', (tester) async {
    await abrirAplicacion(tester);
    await tester.tap(find.text('Crear cuenta'));
    await esperarRespuesta(tester);

    await tester.tap(find.text('Iniciar sesión'));
    await esperarRespuesta(tester);

    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.text('Crea tu cuenta'), findsNothing);
  });
}

/// Abre la aplicación en un teléfono, sin ninguna sesión iniciada.
Future<void> abrirAplicacion(WidgetTester tester) async {
  usarPantallaDeTelefono(tester);
  await tester.pumpWidget(const MiPuestoApp());
  await esperarRespuesta(tester);
}

/// Llena los campos "Correo" y "Contraseña" de la pantalla visible.
Future<void> escribirCuenta(
  WidgetTester tester,
  String correo,
  String contrasena,
) async {
  await tester.enterText(find.byType(TextField).first, correo);
  await tester.enterText(find.byType(TextField).last, contrasena);
  await tester.pump();
}

/// Toca los dígitos de [pin] en el teclado del PIN.
Future<void> escribirPin(WidgetTester tester, String pin) async {
  for (final digito in pin.split('')) {
    await tester.tap(find.text(digito));
  }
  await esperarRespuesta(tester);
}
