import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';

/// El renglón de arriba de una lista: cuántos son a la izquierda y cuánto
/// suman a la derecha. "23 ventas · 1 cancelada      $1,240".
class ResumenDeLista extends StatelessWidget {
  const ResumenDeLista({super.key, required this.texto, required this.total});

  final String texto;

  /// El total ya convertido a texto, por ejemplo `$1,240`.
  final String total;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 12,
      children: [
        Expanded(
          child: Text(
            texto,
            style: Tipografia.texto(15, color: Colores.tintaSuave),
          ),
        ),
        Cifra(total, tamano: 20, peso: 750),
      ],
    );
  }
}
