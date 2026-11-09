import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Botón blanco con borde oscuro: una acción secundaria.
class BotonDeContorno extends StatelessWidget {
  const BotonDeContorno({
    super.key,
    required this.texto,
    required this.alTocar,
    this.icono,
    this.alto = 56,
    this.tamanoDeTexto = 17,
    this.color = Colores.tinta,
    this.fondo = Colores.superficie,
  });

  final String texto;
  final VoidCallback? alTocar;
  final IconData? icono;
  final double alto;
  final double tamanoDeTexto;

  /// Color del borde, del texto y del icono.
  final Color color;

  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      radio: 18,
      decoracion: BoxDecoration(
        color: fondo,
        border: Border.all(color: color, width: 2),
      ),
      child: Container(
        height: alto,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            if (icono != null) Icon(icono, color: color, size: 22),
            Flexible(
              child: Text(
                texto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Tipografia.texto(tamanoDeTexto, peso: 800, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
