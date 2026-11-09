import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Botón redondo con un icono, para sumar o restar una pieza.
class BotonDeCantidad extends StatelessWidget {
  const BotonDeCantidad({
    super.key,
    required this.icono,
    required this.alTocar,
    required this.etiqueta,
    this.esDeSumar = false,
  });

  final IconData icono;
  final VoidCallback alTocar;

  /// Texto para lectores de pantalla, por ejemplo "Quitar un Flan".
  final String etiqueta;

  /// El botón de sumar es rosa; el de restar, blanco con borde.
  final bool esDeSumar;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      etiqueta: etiqueta,
      radio: Radios.pildora,
      decoracion: BoxDecoration(
        color: esDeSumar ? Colores.acentoSuave : Colores.superficie,
        border: esDeSumar ? null : Border.all(color: Colores.tinta, width: 2),
      ),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icono, color: Colores.tinta, size: 22),
      ),
    );
  }
}
