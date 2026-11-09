import 'package:flutter/painting.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

abstract final class Sombras {
  /// Sombra "dura": una franja sólida debajo del elemento, sin difuminar.
  /// Es lo que hace que tarjetas y botones parezcan tener grosor.
  static List<BoxShadow> dura({Color color = Colores.sombra, double alto = 4}) {
    return [BoxShadow(color: color, offset: Offset(0, alto))];
  }

  /// Sombra difuminada para lo que FLOTA encima del contenido (avisos),
  /// como la elevación de Material.
  static const flotante = [
    BoxShadow(color: Color(0x3324181F), offset: Offset(0, 2), blurRadius: 4),
    BoxShadow(color: Color(0x2424181F), offset: Offset(0, 8), blurRadius: 18),
  ];
}
