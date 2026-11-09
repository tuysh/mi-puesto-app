import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// El emoji del producto, en grande. Al tocarlo se abre el selector para
/// cambiarlo; el lapicito de la esquina avisa que se puede tocar.
class BotonDeEmoji extends StatelessWidget {
  const BotonDeEmoji({
    super.key,
    required this.emoji,
    required this.fondo,
    required this.alTocar,
  });

  final String emoji;
  final Color fondo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // Permite que el lapicito sobresalga de la esquina.
      clipBehavior: Clip.none,
      children: [
        CajaTocable(
          alTocar: alTocar,
          etiqueta: 'Cambiar emoji',
          radio: Radios.tarjeta,
          decoracion: BoxDecoration(
            color: fondo,
            boxShadow: Sombras.dura(alto: 3),
          ),
          child: SizedBox(
            width: 72,
            height: 72,
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 36, height: 1.1),
              ),
            ),
          ),
        ),
        const Positioned(right: -8, bottom: -8, child: _InsigniaDeLapiz()),
      ],
    );
  }
}

/// Circulito oscuro con un lápiz. IgnorePointer deja pasar el toque al
/// botón de abajo.
class _InsigniaDeLapiz extends StatelessWidget {
  const _InsigniaDeLapiz();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colores.tinta,
          shape: BoxShape.circle,
          border: Border.all(color: Colores.superficie, width: 3),
        ),
        child: const Icon(
          Icons.edit_rounded,
          color: Colores.superficie,
          size: 14,
        ),
      ),
    );
  }
}
