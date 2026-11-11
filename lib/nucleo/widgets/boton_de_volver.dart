import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

/// La flecha "‹" para regresar a la pantalla anterior.
class BotonDeVolver extends StatelessWidget {
  const BotonDeVolver({super.key, required this.alTocar, this.etiqueta});

  final VoidCallback alTocar;

  /// Texto para lectores de pantalla; si es `null`, "Volver".
  final String? etiqueta;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      // Lleva la flecha al margen, alineada con lo que hay debajo.
      offset: const Offset(-8, 0),
      child: IconButton(
        tooltip: etiqueta ?? 'Volver',
        onPressed: alTocar,
        icon: const Icon(Icons.chevron_left_rounded, size: 32),
        color: Colores.tinta,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      ),
    );
  }
}
