import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Un número (dinero o cantidad) con la tipografía de cifras.
class Cifra extends StatelessWidget {
  const Cifra(
    this.texto, {
    super.key,
    required this.tamano,
    this.peso = 700,
    this.color = Colores.tinta,
  });

  final String texto;
  final double tamano;
  final int peso;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      maxLines: 1,
      style: Tipografia.cifra(tamano, peso: peso, color: color),
    );
  }
}
