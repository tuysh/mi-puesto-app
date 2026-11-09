import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// El botón oscuro "Cobrar →" dentro de la barra del pedido.
class BotonDeCobrar extends StatelessWidget {
  const BotonDeCobrar({super.key, required this.alTocar});

  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      radio: 16,
      decoracion: const BoxDecoration(color: Colores.tinta),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          spacing: 8,
          children: [
            Text(
              'Cobrar',
              style: Tipografia.titulo(
                20,
                peso: 700,
                color: Colores.superficie,
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colores.superficie,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
