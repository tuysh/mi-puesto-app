import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Un párrafo gris que explica algo de la pantalla: para qué sirve una
/// lista, qué pasa al guardar…
class TextoDeAyuda extends StatelessWidget {
  const TextoDeAyuda(
    this.texto, {
    super.key,
    this.tamano = 14,
    this.peso = 600,
    this.centrado = false,
  });

  final String texto;
  final double tamano;
  final int peso;
  final bool centrado;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: centrado ? TextAlign.center : TextAlign.start,
      style: Tipografia.texto(
        tamano,
        peso: peso,
        color: Colores.tintaSuave,
        altura: 1.4,
      ),
    );
  }
}
