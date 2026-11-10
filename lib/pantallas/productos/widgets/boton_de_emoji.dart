import 'package:flutter/widgets.dart';
import 'package:mi_puesto/pantallas/productos/widgets/boton_con_lapiz.dart';

/// El emoji de una categoría, en grande. Al tocarlo se abre el selector
/// para cambiarlo.
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
    return BotonConLapiz(
      etiqueta: 'Cambiar emoji',
      fondo: fondo,
      alTocar: alTocar,
      child: Text(emoji, style: const TextStyle(fontSize: 36, height: 1.1)),
    );
  }
}
