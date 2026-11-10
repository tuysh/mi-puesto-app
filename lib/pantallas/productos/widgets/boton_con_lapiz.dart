import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Un cuadro grande que se toca para cambiar lo que muestra (el emoji de
/// una categoría, la imagen de un producto). El lapicito de la esquina
/// avisa que se puede tocar.
class BotonConLapiz extends StatelessWidget {
  const BotonConLapiz({
    super.key,
    required this.child,
    required this.etiqueta,
    required this.fondo,
    required this.alTocar,
  });

  /// Lo que se ve dentro del cuadro.
  final Widget child;

  /// Texto para lectores de pantalla: "Cambiar emoji".
  final String etiqueta;

  final Color fondo;
  final VoidCallback alTocar;

  static const tamano = 72.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // Permite que el lapicito sobresalga de la esquina.
      clipBehavior: Clip.none,
      children: [
        CajaTocable(
          alTocar: alTocar,
          etiqueta: etiqueta,
          radio: Radios.tarjeta,
          decoracion: BoxDecoration(
            color: fondo,
            boxShadow: Sombras.dura(alto: 3),
          ),
          child: SizedBox(
            width: tamano,
            height: tamano,
            child: Center(child: child),
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
