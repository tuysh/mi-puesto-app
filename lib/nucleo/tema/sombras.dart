import 'package:flutter/painting.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

abstract final class Sombras {
  /// Sombra "dura": una franja sólida debajo del elemento, sin difuminar.
  /// Es lo que hace que tarjetas y botones parezcan tener grosor.
  static List<BoxShadow> dura({Color color = Colores.sombra, double alto = 4}) {
    return [BoxShadow(color: color, offset: Offset(0, alto))];
  }
}
