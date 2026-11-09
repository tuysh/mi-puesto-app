import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// El "−" de la esquina de una tesela: quita una pieza del pedido sin tener
/// que abrir la lista.
///
/// El círculo que se ve mide 32, pero la zona que responde al toque mide 44
/// para que sea fácil de atinar con el dedo.
class BotonDeQuitarPieza extends StatelessWidget {
  const BotonDeQuitarPieza({
    super.key,
    required this.alTocar,
    required this.etiqueta,
  });

  final VoidCallback alTocar;

  /// Texto para lectores de pantalla, por ejemplo "Quitar un Flan".
  final String etiqueta;

  /// Lado de la zona que responde al toque.
  static const zonaDeToque = 44.0;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      etiqueta: etiqueta,
      radio: Radios.pildora,
      child: SizedBox.square(
        dimension: zonaDeToque,
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colores.tinta,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.remove_rounded,
              color: Colores.superficie,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
