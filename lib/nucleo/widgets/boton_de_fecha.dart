import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Un botón con forma de campo que muestra una fecha (o un rango de
/// fechas) y, al tocarlo, deja cambiarla en un calendario.
class BotonDeFecha extends StatelessWidget {
  const BotonDeFecha({
    super.key,
    required this.texto,
    required this.alTocar,
    this.conFlecha = false,
    this.alto = 52,
  });

  /// La fecha ya convertida a texto: "Hoy, jueves 6 de noviembre".
  final String texto;

  final VoidCallback alTocar;

  /// Con `true` lleva una flechita hacia abajo a la derecha, como una
  /// lista desplegable.
  final bool conFlecha;

  final double alto;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      etiqueta: '$texto. Cambiar',
      radio: Radios.campo,
      decoracion: BoxDecoration(
        color: Colores.superficie,
        border: Border.all(color: Colores.bordeDeCampo, width: 2),
      ),
      child: Container(
        height: alto,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          spacing: 10,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Colores.tinta,
              size: 20,
            ),
            Expanded(
              // FittedBox encoge el texto si el rango de fechas no cabe.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(texto, maxLines: 1, style: Tipografia.texto(16)),
              ),
            ),
            if (conFlecha)
              const Icon(
                Icons.expand_more_rounded,
                color: Colores.tinta,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
