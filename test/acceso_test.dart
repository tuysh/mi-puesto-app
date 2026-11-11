import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/datos/conexiones.dart';

import 'ayudas.dart';

/// Recorre las pantallas para entrar con los datos simulados: iniciar
/// sesión, crear cuenta (con su PIN y su nombre), elegir quién vende y
/// cerrar sesión.
void main() {
  /// Abre la aplicación como en un dispositivo que nunca ha iniciado
  /// sesión.
  Future<void> abrirSinSesion(WidgetTester tester) {
    return abrirAplicacion(tester, conexiones: Conexiones.simuladas());
  }

  /// Escribe el correo y la contraseña en "Inicia sesión".
  Future<void> escribirCuenta(
    WidgetTester tester,
    String correo,
    String contrasena,
  ) async {
    await tester.enterText(find.byType(TextField).at(0), correo);
    await tester.enterText(find.byType(TextField).at(1), contrasena);
    await tester.pump();
  }

  testWidgets('sin sesión, la aplicación abre en "Inicia sesión"', (
    tester,
  ) async {
    await abrirSinSesion(tester);

    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.text('¿Quién vende hoy?'), findsNothing);
  });

  testWidgets('con la cuenta de ejemplo se llega a "¿Quién vende hoy?"', (
    tester,
  ) async {
    await abrirSinSesion(tester);

    await escribirCuenta(tester, 'mari@ejemplo.com', 'pay-de-limon');
    await tester.tap(find.text('Entrar'));
    await esperarRespuesta(tester);

    expect(find.text('¿Quién vende hoy?'), findsOneWidget);
    expect(find.text('Mari'), findsOneWidget);
    expect(find.text('Dueña'), findsOneWidget);
    expect(find.text('Lupe'), findsOneWidget);
    expect(find.text('Toño'), findsOneWidget);
  });

  testWidgets('una contraseña incorrecta no deja entrar', (tester) async {
    await abrirSinSesion(tester);

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
    await abrirSinSesion(tester);
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

  testWidgets('un PIN incorrecto no deja entrar', (tester) async {
    await abrirAplicacion(tester);

    await entrarComo(tester, 'Mari', '9999');

    expect(find.text('PIN incorrecto. Intenta otra vez'), findsOneWidget);
    expect(find.text('Hola, Mari'), findsOneWidget);
  });

  testWidgets('crear una cuenta pide el PIN dos veces y luego el nombre', (
    tester,
  ) async {
    await abrirSinSesion(tester);

    await tester.ensureVisible(find.text('Crear cuenta'));
    await tester.tap(find.text('Crear cuenta'));
    await esperarRespuesta(tester);
    expect(find.text('Crea tu cuenta'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Tacos Chela');
    await tester.enterText(find.byType(TextField).at(1), 'chela@ejemplo.com');
    await tester.enterText(find.byType(TextField).at(2), 'salsa-verde');
    await tocarBotonPrincipal(tester, 'Crear cuenta');

    // Paso 1: el PIN.
    expect(find.text('Paso 1 de 3'), findsOneWidget);
    expect(find.text('Crea tu PIN'), findsOneWidget);
    await escribirPin(tester, '4321');
    await tester.tap(find.text('Continuar'));
    await esperarRespuesta(tester);

    // Paso 2: si no es igual al primero, hay que empezar de nuevo.
    expect(find.text('Repite el PIN'), findsOneWidget);
    await escribirPin(tester, '1111');
    expect(
      find.text('No es igual al primero. Empieza de nuevo.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Empezar de nuevo'));
    await esperarRespuesta(tester);
    await escribirPin(tester, '4321');
    await tester.tap(find.text('Continuar'));
    await esperarRespuesta(tester);
    await escribirPin(tester, '4321');
    await tester.tap(find.text('Guardar PIN'));
    await esperarRespuesta(tester);

    // Paso 3: el nombre. La tarjeta de muestra se va llenando.
    expect(find.text('¿Cómo te llamas?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Chela');
    await tester.pump();
    expect(find.text('C'), findsOneWidget);
    await tester.ensureVisible(find.text('Guardar nombre'));
    await tester.tap(find.text('Guardar nombre'));
    await esperarRespuesta(tester);

    // Ya dentro, sin volver a escribir el PIN. Un negocio nuevo no tiene
    // caja abierta: lo primero es abrirla.
    expect(find.text('Abre la caja para empezar'), findsOneWidget);
    final sesion = dependenciasDe(tester).sesion;
    expect(sesion.nombreDelNegocio, 'Tacos Chela');
    expect(sesion.perfil?.nombre, 'Chela');
    expect(sesion.esDuena, isTrue);
  });

  testWidgets('no se puede crear una cuenta con un correo ya usado', (
    tester,
  ) async {
    await abrirSinSesion(tester);
    await tester.ensureVisible(find.text('Crear cuenta'));
    await tester.tap(find.text('Crear cuenta'));
    await esperarRespuesta(tester);

    await tester.enterText(find.byType(TextField).at(0), 'Otro puesto');
    await tester.enterText(find.byType(TextField).at(1), 'mari@ejemplo.com');
    await tester.enterText(find.byType(TextField).at(2), 'otra-clave');
    await tocarBotonPrincipal(tester, 'Crear cuenta');

    expect(find.text('Ya hay una cuenta con ese correo.'), findsOneWidget);
    expect(find.text('Crea tu cuenta'), findsOneWidget);
  });

  testWidgets('tocar a quien está dentro deja entrar a otra persona', (
    tester,
  ) async {
    await abrirComoDuena(tester);

    // La pastilla de arriba a la derecha lleva el nombre de quien entró.
    await tester.tap(find.text('Mari'));
    await esperarRespuesta(tester);

    expect(find.text('¿Quién vende hoy?'), findsOneWidget);
    expect(dependenciasDe(tester).sesion.perfil, isNull);
  });

  testWidgets('"Cerrar sesión" está en Más y vuelve a pedir la cuenta', (
    tester,
  ) async {
    await abrirComoDuena(tester);
    await tester.tap(find.text('Más'));
    await esperarRespuesta(tester);

    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.tap(find.text('Cerrar sesión'));
    await esperarRespuesta(tester);
    expect(find.text('¿Cerrar sesión?'), findsOneWidget);
    await tocarBotonPrincipal(tester, 'Cerrar sesión');

    expect(find.text('Inicia sesión'), findsOneWidget);
  });
}
