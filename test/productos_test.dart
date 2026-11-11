import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/foto_nueva.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/pedir_foto.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/nucleo/widgets/interruptor.dart';
import 'package:mi_puesto/pantallas/productos/letras_sugeridas.dart';
import 'package:mi_puesto/pantallas/productos/widgets/boton_con_lapiz.dart';
import 'package:mi_puesto/pantallas/productos/widgets/fila_de_producto_en_lista.dart';
import 'package:mi_puesto/pantallas/productos/widgets/panel_de_emojis.dart';

import 'ayudas.dart';

/// La pantalla "Productos" y su formulario, con los datos simulados: los
/// tamaños, "Hay hoy", desactivar y cómo se ve el producto al vender.
void main() {
  /// El producto llamado [nombre], como está guardado en el catálogo.
  Producto productoGuardado(WidgetTester tester, String nombre) {
    return dependenciasDe(tester).catalogo.productos
        .firstWhere((producto) => producto.nombre == nombre);
  }

  testWidgets('un producto nuevo se puede vender en varios tamaños', (
    tester,
  ) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Productos');

    await tocarBotonPrincipal(tester, 'Nuevo producto');
    expect(find.text('Nuevo producto'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'Pozole');
    await tester.tap(find.text('Varios tamaños'));
    await esperarRespuesta(tester);

    // Al pasar a tamaños se ofrecen dos renglones: nombre y precio.
    await tester.enterText(find.byType(TextField).at(1), 'Chico');
    await tester.enterText(find.byType(TextField).at(2), '70');
    await tester.enterText(find.byType(TextField).at(3), 'Grande');
    await tester.enterText(find.byType(TextField).at(4), '95');
    await tocarBotonPrincipal(tester, 'Guardar producto');
    await esperarAQueSeQuiteElAviso(tester);

    final pozole = productoGuardado(tester, 'Pozole');
    expect(pozole.precio, isNull);
    expect(pozole.presentaciones.map((tamano) => tamano.nombre), [
      'Chico',
      'Grande',
    ]);
    expect(pozole.precioDesde, const Dinero.pesos(70));
    expect(pozole.categoriaId, isNull);
  });

  testWidgets('de varios tamaños se puede pasar a un solo precio', (
    tester,
  ) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Productos');

    await tester.ensureVisible(find.text('Horchata'));
    await tester.tap(find.text('Horchata'));
    await esperarRespuesta(tester);
    expect(find.text('Tamaños y precios'), findsOneWidget);

    await tester.tap(find.text('Un solo precio'));
    await esperarRespuesta(tester);
    await tester.enterText(find.byType(TextField).at(1), '20');
    await tocarBotonPrincipal(tester, 'Guardar cambios');

    final horchata = productoGuardado(tester, 'Horchata');
    expect(horchata.precio, const Dinero.pesos(20));
    expect(horchata.presentaciones, isEmpty);
  });

  testWidgets('"Hay hoy" se prende y se apaga desde la lista', (tester) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Productos');

    expect(productoGuardado(tester, 'Flan').disponible, isTrue);
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(FilaDeProductoEnLista, 'Flan'),
        matching: find.byType(Interruptor),
      ),
    );
    await esperarRespuesta(tester);

    expect(productoGuardado(tester, 'Flan').disponible, isFalse);
  });

  testWidgets('un producto desactivado sale de la lista', (tester) async {
    await abrirComoDuena(tester);
    await abrirDesdeMas(tester, 'Productos');
    await tester.tap(find.text('Flan'));
    await esperarRespuesta(tester);

    await tester.tap(find.text('Desactivar producto'));
    await esperarRespuesta(tester);
    expect(find.text('¿Desactivar Flan?'), findsOneWidget);
    await tocarBotonPrincipal(tester, 'Desactivar');

    expect(find.text('Productos'), findsOneWidget);
    expect(find.text('Flan'), findsNothing);
  });

  testWidgets('en tablet el formulario va junto a la tabla', (tester) async {
    await abrirComoDuena(tester, enTablet: true);
    await abrirDesdeMas(tester, 'Productos');

    expect(find.text('14 productos · 13 hay hoy'), findsOneWidget);
    // El riel sigue a la vista: "Más" tiene su propio navegador.
    expect(find.text('Reportes'), findsOneWidget);

    await tester.tap(find.text('Esquite').first);
    await esperarRespuesta(tester);
    final nombre = tester.widget<TextField>(find.byType(TextField).first);
    expect(nombre.controller!.text, 'Esquite');
  });

  group('¿Cómo se ve al vender?', () {
    /// Abre el formulario del flan y toca su imagen.
    Future<void> abrirImagenDelFlan(
      WidgetTester tester, {
      PedirFoto? pedirFoto,
    }) async {
      await abrirComoDuena(tester, pedirFoto: pedirFoto);
      await abrirDesdeMas(tester, 'Productos');
      await tester.tap(find.text('Flan'));
      await esperarRespuesta(tester);
      await tester.tap(find.byType(BotonConLapiz));
      await esperarRespuesta(tester);
    }

    /// La imagen que muestra el botón del formulario.
    ImagenDeProducto imagenDelFormulario(WidgetTester tester) {
      return tester.widget<ImagenDeProducto>(
        find.descendant(
          of: find.byType(BotonConLapiz),
          matching: find.byType(ImagenDeProducto),
        ),
      );
    }

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

      // Propone las primeras letras del nombre y no deja pasar de dos.
      final campo = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextField),
      );
      expect(tester.widget<TextField>(campo).controller!.text, 'Fl');
      await tester.enterText(campo, '');
      await tester.enterText(campo, 'Fn');
      await tester.pump();
      // Con dos letras ya escritas, una tercera no entra.
      await tester.enterText(campo, 'Fna');
      await tester.pump();
      expect(tester.widget<TextField>(campo).controller!.text, 'Fn');

      await tester.tap(find.text('Usar estas letras'));
      await esperarRespuesta(tester);
      expect(imagenDelFormulario(tester).letras, 'Fn');
      expect(imagenDelFormulario(tester).emoji, isEmpty);

      // Al guardar, el producto queda pintado con letras.
      await tocarBotonPrincipal(tester, 'Guardar cambios');
      final flan = productoGuardado(tester, 'Flan');
      expect(flan.representacion, Representacion.letras);
      expect(flan.letras, 'Fn');
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

      // La foto se sube al guardar el producto (son dos viajes al
      // servidor: el producto y su foto).
      expect(productoGuardado(tester, 'Flan').imagenUrl, isEmpty);
      await tocarBotonPrincipal(tester, 'Guardar cambios');
      await esperarRespuesta(tester);
      var flan = productoGuardado(tester, 'Flan');
      expect(flan.representacion, Representacion.imagen);
      expect(flan.imagenUrl, isNotEmpty);
      await esperarAQueSeQuiteElAviso(tester);

      // Volver a un emoji le quita la foto.
      await tester.tap(find.text('Flan'));
      await esperarRespuesta(tester);
      await tester.tap(find.byType(BotonConLapiz));
      await esperarRespuesta(tester);
      await tester.tap(find.text('Emoji'));
      await esperarRespuesta(tester);
      await tester.tap(find.text('Usar este emoji'));
      await esperarRespuesta(tester);
      await tocarBotonPrincipal(tester, 'Guardar cambios');
      await esperarRespuesta(tester);
      await esperarRespuesta(tester);
      flan = productoGuardado(tester, 'Flan');
      expect(flan.representacion, Representacion.emoji);
      expect(flan.imagenUrl, isEmpty);
      expect(flan.emoji, '🍮');
    });
  });

  test('las letras sugeridas salen del nombre', () {
    expect(sugerirLetras('Pay de limón'), 'PL');
    expect(sugerirLetras('Tostilocos'), 'To');
    expect(sugerirLetras('Agua de horchata'), 'AH');
    expect(sugerirLetras('Té'), 'Té');
    expect(sugerirLetras('  '), '');
  });
}

/// Una imagen PNG diminuta (2 × 2 puntos rosas), válida de verdad.
final fotoDePrueba = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEklEQVR4nGM4opV0RCuJAUIBACZWBUHn+eHKAAAAAElFTkSuQmCC',
);
