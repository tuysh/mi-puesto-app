import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// El emoji del producto, en grande. Al tocarlo se puede cambiar.
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
    return CajaTocable(
      alTocar: alTocar,
      etiqueta: 'Cambiar emoji',
      radio: Radios.tarjeta,
      decoracion: BoxDecoration(color: fondo, boxShadow: Sombras.dura(alto: 3)),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 36, height: 1.1)),
        ),
      ),
    );
  }
}
