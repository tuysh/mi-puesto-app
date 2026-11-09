import 'package:flutter/widgets.dart';

/// Radios de las esquinas redondeadas más usados.
abstract final class Radios {
  /// Tan grande que el resultado siempre es una píldora o un círculo.
  static const pildora = 999.0;

  static const tarjetaGrande = 26.0;
  static const tarjeta = 22.0;
  static const boton = 20.0;
  static const campo = 16.0;
}

/// A partir de este ancho usamos el diseño de tablet (en horizontal).
const anchoMinimoDeTablet = 900.0;

/// Indica si la pantalla es lo bastante ancha para el diseño de tablet.
bool esTablet(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= anchoMinimoDeTablet;
}
