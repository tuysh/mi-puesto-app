import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/app/mi_puesto_app.dart';
import 'package:mi_puesto/datos/conexiones.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/pantallas/caja/pantalla_de_cierre.dart';

import 'flujo_de_venta_test.dart';

/// Cerrar la caja y volver a abrirla, con los datos simulados.
void main() {
  testWidgets('después de cerrar la caja se puede abrir otra', (tester) async {
    await cargarFuentes();
    usarPantallaDeTelefono(tester);
    await tester.pumpWidget(
      MiPuestoApp(conexiones: Conexiones.simuladas(conSesionIniciada: true)),
    );
    await esperarRespuesta(tester);

    Future<void> abrirCierre() async {
      final contexto = tester.element(find.byType(Scaffold).last);
      expect(Dependencias.de(contexto), isNotNull);
      abrirPantalla(contexto, const PantallaDeCierre());
      await esperarRespuesta(tester);
    }

    // La caja simulada empieza abierta con $500 y $1,240 vendidos.
    await abrirCierre();
    expect(find.text('¿Cuánto contaste en la caja?'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '1740');
    await tester.pump();
    await tester.tap(find.text('Cerrar caja de hoy'));
    await esperarRespuesta(tester);
    expect(find.text('Caja cerrada'), findsOneWidget);
    // Deja que el aviso se quite solo, para que no tape el botón.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Ya sin caja abierta, la misma pantalla ofrece abrir una.
    await abrirCierre();
    expect(find.text('Todavía no has abierto la caja'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '300');
    await tester.tap(find.text('Abrir caja'));
    await esperarRespuesta(tester);

    expect(find.text('¿Cuánto contaste en la caja?'), findsOneWidget);
    expect(find.text('\$300'), findsWidgets);
  });
}

/// Carga las tipografías de verdad. Sin esto las pruebas dibujan cada letra
/// como un cuadro ancho y los renglones largos de la caja no caben.
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
