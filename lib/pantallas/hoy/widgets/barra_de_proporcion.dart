import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';

/// Barra horizontal que se llena según [fraccion]: 0 es vacía y 1 es llena.
class BarraDeProporcion extends StatelessWidget {
  const BarraDeProporcion({super.key, required this.fraccion});

  final double fraccion;

  static const _alto = 8.0;

  @override
  Widget build(BuildContext context) {
    final esquinas = BorderRadius.circular(Radios.pildora);

    return Container(
      height: _alto,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colores.superficieHundida,
        borderRadius: esquinas,
      ),
      // FractionallySizedBox hace que la parte oscura ocupe solo una
      // fracción del ancho total.
      child: FractionallySizedBox(
        widthFactor: fraccion.clamp(0, 1),
        child: Container(
          decoration: BoxDecoration(
            color: Colores.tinta,
            borderRadius: esquinas,
          ),
        ),
      ),
    );
  }
}
