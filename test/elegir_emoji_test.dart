import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/app/mi_puesto_app.dart';
import 'package:mi_puesto/datos/conexiones.dart';
import 'package:mi_puesto/datos/modelos/foto_nueva.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/pantallas/productos/letras_sugeridas.dart';
import 'package:mi_puesto/pantallas/productos/widgets/boton_con_lapiz.dart';
import 'package:mi_puesto/pantallas/productos/widgets/panel_de_emojis.dart';

import 'flujo_de_venta_test.dart';

/// Un producto se puede ver al vender con un emoji, con letras o con una
/// foto. Se elige en la hoja "¿Cómo se ve al vender?".
void main() {
  testWidgets('se puede cambiar el emoji de un producto', (tester) async {
    await abrirImagenDelFlan(tester);
    expect(find.text('¿Cómo se ve al vender?'), findsOneWidget);

    // El emoji se elige tocando, nunca escribiendo: en este modo la hoja
    // no tiene dónde escribir.
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

    expect(imagenDelFormulario(tester).emoji, '🍍');
  });

  testWidgets('se pueden usar letras en vez de emoji', (tester) async {
    await abrirImagenDelFlan(tester);

    await tester.tap(find.text('Letras'));
    await esperarRespuesta(tester);
    expect(find.byType(PanelDeEmojis), findsNothing);

    // Propone las iniciales del nombre y no deja pasar de dos letras.
    final campo = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(campo).controller!.text, 'FN');
    await tester.enterText(campo, '');
    await tester.enterText(campo, 'Fl');
    await tester.pump();
    // Con dos letras ya escritas, una tercera no entra.
    await tester.enterText(campo, 'Fla');
    await tester.pump();
    expect(tester.widget<TextField>(campo).controller!.text, 'Fl');

    await tester.tap(find.text('Usar estas letras'));
    await esperarRespuesta(tester);
    expect(imagenDelFormulario(tester).letras, 'Fl');
    expect(imagenDelFormulario(tester).emoji, isEmpty);

    // Al guardar, el producto queda con letras y sin emoji.
    await tester.tap(find.text('Guardar cambios'));
    await esperarGuardado(tester);
    final flan = productoGuardado(tester, 'Flan napolitano');
    expect(flan.letras, 'Fl');
    expect(flan.emoji, isEmpty);
  });

  testWidgets('se puede poner una foto y luego volver al emoji', (
    tester,
  ) async {
    final fuentes = <bool>[];
    await abrirImagenDelFlan(
      tester,
      pedirFoto: ({required bool conCamara}) async {
        fuentes.add(conCamara);
        return FotoNueva(bytes: fotoDePrueba, nombreDeArchivo: 'flan.png');
      },
    );

    await tester.tap(find.text('Foto'));
    await esperarRespuesta(tester);

    // Sin foto todavía, no hay nada que usar: el botón no hace nada.
    await tester.tap(find.text('Usar esta foto'));
    await esperarRespuesta(tester);
    expect(find.text('¿Cómo se ve al vender?'), findsOneWidget);

    await tester.tap(find.text('Elegir de la galería'));
    await esperarRespuesta(tester);
    expect(fuentes, [false]);
    await tester.tap(find.text('Usar esta foto'));
    await esperarRespuesta(tester);
    expect(imagenDelFormulario(tester).fotoLocal, fotoDePrueba);

    // La foto se sube al guardar el producto.
    expect(productoGuardado(tester, 'Flan napolitano').fotoUrl, isEmpty);
    await tester.tap(find.text('Guardar cambios'));
    await esperarGuardado(tester);
    expect(productoGuardado(tester, 'Flan napolitano').fotoUrl, isNotEmpty);

    // Volver a un emoji le quita la foto.
    await tester.tap(find.text('Flan napolitano'));
    await esperarRespuesta(tester);
    await tester.tap(find.byType(BotonConLapiz));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Emoji'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Usar este emoji'));
    await esperarRespuesta(tester);
    await tester.tap(find.text('Guardar cambios'));
    await esperarGuardado(tester);
    final flan = productoGuardado(tester, 'Flan napolitano');
    expect(flan.fotoUrl, isEmpty);
    expect(flan.emoji, '🍮');
  });

  test('las letras sugeridas salen del nombre', () {
    expect(sugerirLetras('Pay de limón'), 'PL');
    expect(sugerirLetras('Tostilocos'), 'To');
    expect(sugerirLetras('Agua de horchata'), 'AH');
    expect(sugerirLetras('Té'), 'Té');
    expect(sugerirLetras('  '), '');
  });
}

/// Guardar son dos viajes al servidor simulado: el producto y su foto.
Future<void> esperarGuardado(WidgetTester tester) async {
  await esperarRespuesta(tester);
  await esperarRespuesta(tester);
}

/// Una imagen PNG diminuta (2 × 2 puntos rosas), válida de verdad.
final fotoDePrueba = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEklEQVR4nGM4opV0RCuJAUIBACZWBUHn+eHKAAAAAElFTkSuQmCC',
);

/// Entra a la aplicación, abre el formulario del flan y toca su imagen.
Future<void> abrirImagenDelFlan(
  WidgetTester tester, {
  Future<FotoNueva?> Function({required bool conCamara})? pedirFoto,
}) async {
  usarPantallaDeTelefono(tester);
  await tester.pumpWidget(
    MiPuestoApp(
      conexiones: Conexiones.simuladas(conSesionIniciada: true),
      pedirFoto: pedirFoto ?? ({required bool conCamara}) async => null,
    ),
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
  await tester.tap(find.text('Más'));
  await esperarRespuesta(tester);
  await tester.tap(find.text('Productos'));
  await esperarRespuesta(tester);

  await tester.tap(find.text('Flan napolitano'));
  await esperarRespuesta(tester);
  await tester.tap(find.byType(BotonConLapiz));
  await esperarRespuesta(tester);
}

/// La imagen que muestra el botón grande del formulario.
ImagenDeProducto imagenDelFormulario(WidgetTester tester) {
  return tester.widget<ImagenDeProducto>(
    find.descendant(
      of: find.byType(BotonConLapiz),
      matching: find.byType(ImagenDeProducto),
    ),
  );
}

/// El producto llamado [nombre], como está guardado en el catálogo.
dynamic productoGuardado(WidgetTester tester, String nombre) {
  final contexto = tester.element(find.byType(Scaffold).first);
  return Dependencias.de(contexto).catalogo.productos
      .firstWhere((producto) => producto.nombre == nombre);
}
