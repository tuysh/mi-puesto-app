import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Un botón del filtro de categorías. El elegido se pinta oscuro.
class BotonDeFiltro extends StatelessWidget {
  const BotonDeFiltro({
    super.key,
    required this.texto,
    required this.colores,
    required this.estaElegido,
    required this.alTocar,
    this.conBorde = false,
  });

  final String texto;

  /// Colores del botón mientras NO está elegido.
  final ParDeColores colores;

  final bool estaElegido;
  final VoidCallback alTocar;

  /// Dibuja un borde claro mientras no está elegido. Hace falta en "Todo",
  /// que es blanco y sin borde se perdería en el fondo.
  final bool conBorde;

  @override
  Widget build(BuildContext context) {
    final fondo = estaElegido ? Colores.tinta : colores.fondo;
    final tinta = estaElegido ? Colores.superficie : colores.tinta;
    final dibujarBorde = conBorde && !estaElegido;

    return CajaTocable(
      alTocar: alTocar,
      radio: Radios.pildora,
      decoracion: BoxDecoration(
        color: fondo,
        border: dibujarBorde
            ? Border.all(color: Colores.borde, width: 2)
            : null,
      ),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          widthFactor: 1,
          child: Text(
            texto,
            style: Tipografia.texto(15, peso: 800, color: tinta),
          ),
        ),
      ),
    );
  }
}
