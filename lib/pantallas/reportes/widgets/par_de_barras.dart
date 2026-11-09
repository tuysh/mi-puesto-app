import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Dos barras verticales juntas: lo vendido (oscura) y la ganancia (verde).
class ParDeBarras extends StatelessWidget {
  const ParDeBarras({
    super.key,
    required this.altoDeVendido,
    required this.altoDeGanancia,
  });

  final double altoDeVendido;
  final double altoDeGanancia;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // Alinea las dos barras por abajo, para que "crezcan" desde el piso.
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 3,
      children: [
        _Barra(alto: altoDeVendido, color: Colores.tinta),
        _Barra(alto: altoDeGanancia, color: Colores.barraDeGanancia),
      ],
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.alto, required this.color});

  final double alto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 13,
      height: alto,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
      ),
    );
  }
}
