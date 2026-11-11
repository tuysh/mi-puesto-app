/// Lo que comparten las pruebas que recorren la aplicación con los datos
/// simulados.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/app/mi_puesto_app.dart';
import 'package:mi_puesto/datos/conexiones.dart';
import 'package:mi_puesto/nucleo/pedir_foto.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';

/// Abre la aplicación del tamaño de un teléfono (o de una tablet) con los
/// datos simulados.
///
/// Si no se indican [conexiones], arranca con la sesión de la cuenta de
/// ejemplo ya iniciada: lo primero que se ve es "¿Quién vende hoy?".
Future<void> abrirAplicacion(
  WidgetTester tester, {
  Conexiones? conexiones,
  PedirFoto? pedirFoto,
  bool enTablet = false,
}) async {
  await cargarFuentes();
  tester.view.physicalSize = enTablet
      ? const Size(1280, 800)
      : const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MiPuestoApp(
      conexiones: conexiones ?? Conexiones.simuladas(conSesionIniciada: true),
      pedirFoto: pedirFoto ?? ({required bool conCamara}) async => null,
    ),
  );
  await esperarRespuesta(tester);
}

/// En "¿Quién vende hoy?": toca a [nombre], escribe su [pin] y entra.
Future<void> entrarComo(WidgetTester tester, String nombre, String pin) async {
  await tester.tap(find.text(nombre));
  await esperarRespuesta(tester);
  await escribirPin(tester, pin);
  await tester.tap(find.text('Entrar'));
  await esperarRespuesta(tester);
}

/// Toca en el teclado del PIN los dígitos de [pin], uno por uno.
Future<void> escribirPin(WidgetTester tester, String pin) async {
  for (final digito in pin.split('')) {
    await tester.tap(find.text(digito));
  }
  await esperarRespuesta(tester);
}

/// Abre la aplicación y entra como Mari, la dueña del negocio de ejemplo.
Future<void> abrirComoDuena(
  WidgetTester tester, {
  Conexiones? conexiones,
  PedirFoto? pedirFoto,
  bool enTablet = false,
}) async {
  await abrirAplicacion(
    tester,
    conexiones: conexiones,
    pedirFoto: pedirFoto,
    enTablet: enTablet,
  );
  await entrarComo(tester, 'Mari', '1234');
}

/// Desde cualquier pestaña: abre "Más" y toca la opción [opcion].
Future<void> abrirDesdeMas(WidgetTester tester, String opcion) async {
  await tester.tap(find.text('Más'));
  await esperarRespuesta(tester);
  await tester.tap(find.text(opcion));
  await esperarRespuesta(tester);
}

/// Toca el botón principal (el oscuro) que dice [texto]. Sirve cuando el
/// mismo texto aparece también en otro lado, como en el título.
Future<void> tocarBotonPrincipal(WidgetTester tester, String texto) async {
  final boton = find.widgetWithText(BotonPrincipal, texto);
  await tester.ensureVisible(boton);
  await tester.tap(boton);
  await esperarRespuesta(tester);
}

/// Deja pasar el tiempo que tarda en "responder" el servidor simulado y
/// espera a que terminen las animaciones.
Future<void> esperarRespuesta(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
}

/// Deja que el aviso de abajo ("Cambios guardados") se quite solo, para
/// que no tape lo que sigue.
Future<void> esperarAQueSeQuiteElAviso(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

/// Los objetos compartidos de la aplicación, para revisar cómo quedaron
/// los datos después de tocar la pantalla.
Dependencias dependenciasDe(WidgetTester tester) {
  return Dependencias.de(tester.element(find.byType(Scaffold).first));
}

/// Carga las tipografías de verdad. Sin esto las pruebas dibujan cada letra
/// como un cuadro ancho y los renglones largos no caben.
Future<void> cargarFuentes() async {
  const archivos = {
    'Figtree': 'assets/fuentes/Figtree.ttf',
    'Bricolage Grotesque': 'assets/fuentes/BricolageGrotesque.ttf',
  };

  for (final MapEntry(key: familia, value: archivo) in archivos.entries) {
    final bytes = File(archivo).readAsBytesSync();
    final cargador = FontLoader(familia)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await cargador.load();
  }
}
