// Genera el icono de la aplicación a partir del widget [LogoDelPuesto], el
// mismo emblema que se ve en la pantalla del PIN.
//
// Si el logo cambia, vuelve a generar los iconos con:
//
//     flutter test herramientas/generar_iconos.dart
//
// Se ejecuta con `flutter test` porque es la forma más sencilla de pintar un
// widget sin abrir la aplicación; no es una prueba.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/logo_del_puesto.dart';

import 'png_sin_transparencia.dart';

/// Cuánto del icono ocupa el logo cuando el icono se muestra completo.
const _proporcionNormal = 0.66;

/// Cuánto ocupa cuando el sistema recorta el icono en círculo u otra forma
/// (iconos adaptables de Android y "maskable" de la web). Es menor para que
/// el recorte nunca toque el logo.
const _proporcionRecortable = 0.48;

/// Iconos de Android: carpeta y cuántos píxeles mide 1 dp en esa densidad.
const _densidadesDeAndroid = {
  'mipmap-mdpi': 1.0,
  'mipmap-hdpi': 1.5,
  'mipmap-xhdpi': 2.0,
  'mipmap-xxhdpi': 3.0,
  'mipmap-xxxhdpi': 4.0,
};

/// Iconos de iOS: nombre del archivo y su lado en píxeles.
const _iconosDeIos = {
  'Icon-App-20x20@1x.png': 20,
  'Icon-App-20x20@2x.png': 40,
  'Icon-App-20x20@3x.png': 60,
  'Icon-App-29x29@1x.png': 29,
  'Icon-App-29x29@2x.png': 58,
  'Icon-App-29x29@3x.png': 87,
  'Icon-App-40x40@1x.png': 40,
  'Icon-App-40x40@2x.png': 80,
  'Icon-App-40x40@3x.png': 120,
  'Icon-App-60x60@2x.png': 120,
  'Icon-App-60x60@3x.png': 180,
  'Icon-App-76x76@1x.png': 76,
  'Icon-App-76x76@2x.png': 152,
  'Icon-App-83.5x83.5@2x.png': 167,
  'Icon-App-1024x1024@1x.png': 1024,
};

const _carpetaDeAndroid = 'android/app/src/main/res';
const _carpetaDeIos = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';

final _claveDelIcono = GlobalKey();

void main() {
  testWidgets('genera los iconos de la aplicación', (tester) async {
    await _cargarFuenteDeIconos(tester);

    // La imagen original, por si se necesita para otra tienda o plataforma.
    await _guardarIcono(tester, 'assets/icono/icono.png', lado: 1024);

    for (final MapEntry(key: carpeta, value: densidad)
        in _densidadesDeAndroid.entries) {
      // Icono clásico (Android 7 y anteriores): 48 dp.
      await _guardarIcono(
        tester,
        '$_carpetaDeAndroid/$carpeta/ic_launcher.png',
        lado: (48 * densidad).round(),
      );
      // Capa del frente del icono adaptable (Android 8 en adelante): 108 dp.
      // El fondo es un color liso, definido en `values/colors.xml`.
      await _guardarIcono(
        tester,
        '$_carpetaDeAndroid/$carpeta/ic_launcher_frente.png',
        lado: (108 * densidad).round(),
        proporcion: _proporcionRecortable,
        conFondo: false,
      );
    }

    for (final MapEntry(key: archivo, value: lado) in _iconosDeIos.entries) {
      await _guardarIcono(tester, '$_carpetaDeIos/$archivo', lado: lado);
    }

    await _guardarIcono(tester, 'web/favicon.png', lado: 32);
    for (final lado in [192, 512]) {
      await _guardarIcono(tester, 'web/icons/Icon-$lado.png', lado: lado);
      await _guardarIcono(
        tester,
        'web/icons/Icon-maskable-$lado.png',
        lado: lado,
        proporcion: _proporcionRecortable,
      );
    }
  });
}

/// Pinta el icono con [lado] píxeles y lo guarda en [ruta].
///
/// Con [conFondo] en `false` solo se pinta el logo y el resto queda
/// transparente.
Future<void> _guardarIcono(
  WidgetTester tester,
  String ruta, {
  required int lado,
  double proporcion = _proporcionNormal,
  bool conFondo = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size.square(lado.toDouble());
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    RepaintBoundary(
      key: _claveDelIcono,
      child: _Icono(proporcion: proporcion, conFondo: conFondo),
    ),
  );

  // Convertir lo pintado en imagen es trabajo "real" (no simulado por la
  // prueba), por eso va dentro de `runAsync`.
  final bytes = await tester.runAsync(() => _capturar(lado, conFondo));

  final archivo = File(ruta);
  archivo.parent.createSync(recursive: true);
  archivo.writeAsBytesSync(bytes!);
}

Future<Uint8List> _capturar(int lado, bool conFondo) async {
  final lienzo =
      _claveDelIcono.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
  final imagen = await lienzo.toImage();

  if (!conFondo) {
    final png = await imagen.toByteData(format: ui.ImageByteFormat.png);
    return png!.buffer.asUint8List();
  }

  final rgba = await imagen.toByteData(format: ui.ImageByteFormat.rawRgba);
  return codificarPngSinTransparencia(
    rgba: rgba!.buffer.asUint8List(),
    lado: lado,
  );
}

/// El dibujo del icono: el logo del puesto centrado sobre el color de fondo
/// de la aplicación.
class _Icono extends StatelessWidget {
  const _Icono({required this.proporcion, required this.conFondo});

  /// Parte del lado del icono que ocupa el logo (de 0 a 1).
  final double proporcion;

  final bool conFondo;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: conFondo ? Colores.fondo : Colors.transparent,
        child: FractionallySizedBox(
          widthFactor: proporcion,
          heightFactor: proporcion,
          // El logo se pinta a su tamaño normal y FittedBox lo agranda, para
          // que la sombra crezca en la misma proporción que el cuadro.
          child: const FittedBox(
            child: Padding(
              // Deja sitio a la sombra dura, que sobresale 4 px por abajo.
              padding: EdgeInsets.only(bottom: 4),
              child: LogoDelPuesto(),
            ),
          ),
        ),
      ),
    );
  }
}

/// En las pruebas Flutter no carga la fuente de los iconos de Material; sin
/// esto, el puestito del logo saldría como un rectángulo vacío.
Future<void> _cargarFuenteDeIconos(WidgetTester tester) async {
  final carpetaDeFlutter = Platform.environment['FLUTTER_ROOT']!;
  final fuente = File(
    '$carpetaDeFlutter/bin/cache/artifacts/material_fonts/'
    'MaterialIcons-Regular.otf',
  );

  await tester.runAsync(() async {
    final bytes = await fuente.readAsBytes();
    final cargador = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await cargador.load();
  });
}
