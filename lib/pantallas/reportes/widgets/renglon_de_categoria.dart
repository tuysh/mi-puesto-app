import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/nucleo/widgets/pastilla.dart';

/// Una categoría con lo que vendió, y una flecha para ver su detalle.
class RenglonDeCategoria extends StatelessWidget {
  const RenglonDeCategoria({
    super.key,
    required this.nombre,
    required this.colores,
    required this.monto,
    required this.alTocar,
  });

  /// Nombre de la categoría con su emoji: "🍰 Postres".
  final String nombre;

  final ParDeColores colores;

  /// Lo vendido, ya convertido a texto: `$2,980`.
  final String monto;

  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      radio: 12,
      child: SizedBox(
        height: 44,
        child: Row(
          spacing: 10,
          children: [
            Pastilla(texto: nombre, colores: colores),
            const Spacer(),
            Cifra(monto, tamano: 18),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colores.tintaSuave,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
