import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Un emoji de la cuadrícula del selector. El elegido se marca con borde
/// oscuro y fondo rosa.
class CasillaDeEmoji extends StatelessWidget {
  const CasillaDeEmoji({
    super.key,
    required this.emoji,
    required this.estaElegido,
    required this.alTocar,
  });

  final String emoji;
  final bool estaElegido;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      etiqueta: 'Emoji $emoji',
      radio: 16,
      decoracion: BoxDecoration(
        color: estaElegido ? Colores.acentoSuave : Colores.fondo,
        border: estaElegido ? Border.all(color: Colores.tinta, width: 3) : null,
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 28, height: 1)),
      ),
    );
  }
}
