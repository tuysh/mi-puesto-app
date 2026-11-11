import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Dos flechas para ir al día (o semana, o mes) anterior y al siguiente,
/// con el nombre del actual en medio.
///
/// Si [alIrAlSiguiente] es `null`, la flecha de la derecha se apaga: ya se
/// está en el periodo de hoy y no hay futuro que mirar.
class NavegadorDeFechas extends StatelessWidget {
  const NavegadorDeFechas({
    super.key,
    required this.texto,
    required this.alIrAlAnterior,
    required this.alIrAlSiguiente,
    this.enTarjeta = false,
  });

  /// Lo que se está mirando: "Hoy, jueves 6 de noviembre".
  final String texto;

  final VoidCallback alIrAlAnterior;
  final VoidCallback? alIrAlSiguiente;

  /// Con `true` va dentro de una tarjeta blanca con borde.
  final bool enTarjeta;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: enTarjeta
          ? BoxDecoration(
              color: Colores.superficie,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colores.borde, width: 2),
            )
          : null,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Anterior',
            onPressed: alIrAlAnterior,
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            color: Colores.tinta,
          ),
          Expanded(
            // FittedBox encoge el texto si no cabe entre las flechas ("Lunes
            // 28 de septiembre al domingo 4 de octubre").
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                texto,
                maxLines: 1,
                style: Tipografia.texto(enTarjeta ? 16 : 15, peso: 800),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Siguiente',
            onPressed: alIrAlSiguiente,
            icon: const Icon(Icons.chevron_right_rounded, size: 28),
            color: Colores.tinta,
            disabledColor: Colores.bordePunteado,
          ),
        ],
      ),
    );
  }
}
