import 'package:flutter/painting.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Los tres estilos de texto de la aplicación.
///
/// - [texto]: Figtree, para todo el texto normal.
/// - [titulo]: Bricolage Grotesque, para títulos y botones grandes.
/// - [cifra]: Bricolage Grotesque con números del mismo ancho, para dinero
///   y cantidades (así las columnas de números quedan alineadas).
///
/// El [peso] es el grosor de la letra, de 100 (delgada) a 900 (gruesa).
/// Las fuentes son variables, así que aceptan valores intermedios como 750.
abstract final class Tipografia {
  static const familiaDeTexto = 'Figtree';
  static const familiaDeTitulos = 'Bricolage Grotesque';

  static TextStyle texto(
    double tamano, {
    int peso = 700,
    Color color = Colores.tinta,
    double? altura,
  }) {
    return TextStyle(
      fontFamily: familiaDeTexto,
      fontSize: tamano,
      fontWeight: FontWeight(peso),
      color: color,
      height: altura,
    );
  }

  static TextStyle titulo(
    double tamano, {
    int peso = 750,
    Color color = Colores.tinta,
  }) {
    return TextStyle(
      fontFamily: familiaDeTitulos,
      fontSize: tamano,
      fontWeight: FontWeight(peso),
      color: color,
      letterSpacing: tamano * -0.02,
      height: 1.05,
      fontVariations: [_tamanoOptico(tamano)],
    );
  }

  static TextStyle cifra(
    double tamano, {
    int peso = 700,
    Color color = Colores.tinta,
  }) {
    return TextStyle(
      fontFamily: familiaDeTitulos,
      fontSize: tamano,
      fontWeight: FontWeight(peso),
      color: color,
      letterSpacing: tamano * -0.01,
      height: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontVariations: [_tamanoOptico(tamano)],
    );
  }

  /// Bricolage Grotesque cambia ligeramente de forma según el tamaño al
  /// que se va a leer ("tamaño óptico", de 12 a 96): más abierta en chico
  /// y más compacta en grande. Flutter no lo ajusta solo; se lo indicamos.
  static FontVariation _tamanoOptico(double tamano) {
    return FontVariation('opsz', tamano.clamp(12, 96));
  }
}
