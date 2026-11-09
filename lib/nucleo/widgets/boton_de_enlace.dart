import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Texto rosa que se puede tocar, sin fondo ni borde: la acción menos
/// llamativa ("Vaciar", "Fue exacto", "Cambiar productos").
class BotonDeEnlace extends StatelessWidget {
  const BotonDeEnlace({
    super.key,
    required this.texto,
    required this.alTocar,
    this.icono,
  });

  final String texto;
  final VoidCallback? alTocar;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      radio: 12,
      child: Container(
        // 44 de alto para que sea fácil de tocar con el dedo.
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            if (icono != null) Icon(icono, color: Colores.acento, size: 18),
            Text(
              texto,
              style: Tipografia.texto(15, peso: 800, color: Colores.acento),
            ),
          ],
        ),
      ),
    );
  }
}
