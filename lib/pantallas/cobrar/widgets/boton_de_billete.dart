import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';

/// Botón con un monto de pago ("$200") o con el texto "Otro…".
///
/// Si [alTocar] es `null` se ve apagado: ese billete no alcanza para pagar.
class BotonDeBillete extends StatelessWidget {
  const BotonDeBillete({
    super.key,
    required this.texto,
    required this.estaElegido,
    required this.alTocar,
    this.alto = 56,
  });

  final String texto;
  final bool estaElegido;
  final VoidCallback? alTocar;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final estaApagado = alTocar == null;

    return Opacity(
      opacity: estaApagado ? 0.35 : 1,
      child: CajaTocable(
        alTocar: alTocar,
        radio: Radios.campo,
        decoracion: BoxDecoration(
          color: estaElegido ? Colores.acentoSuave : Colores.superficie,
          border: Border.all(color: Colores.tinta, width: estaElegido ? 4 : 2),
        ),
        child: SizedBox(
          height: alto,
          child: Center(
            // FittedBox encoge el texto si no cabe en el botón.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Cifra(texto, tamano: 19),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
