import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';

/// Un total con doble raya debajo, como se cierran las sumas en una libreta.
class CifraConDobleRaya extends StatelessWidget {
  const CifraConDobleRaya(this.texto, {super.key, required this.tamano});

  final String texto;
  final double tamano;

  static const _grosorDeRaya = 2.0;
  static const _espacioEntreRayas = 2.0;

  @override
  Widget build(BuildContext context) {
    const raya = ColoredBox(
      color: Colores.tinta,
      child: SizedBox(height: _grosorDeRaya, width: double.infinity),
    );

    // IntrinsicWidth hace que las rayas midan lo mismo que el número.
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Cifra(texto, tamano: tamano, peso: 750),
          const SizedBox(height: 6),
          raya,
          const SizedBox(height: _espacioEntreRayas),
          raya,
        ],
      ),
    );
  }
}
