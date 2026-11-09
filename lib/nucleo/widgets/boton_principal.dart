import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// El botón oscuro con sombra rosa: la acción más importante de la pantalla.
///
/// Si [alTocar] es `null` el botón se ve apagado y no responde.
class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.alTocar,
    this.icono,
    this.iconoAlFinal = false,
    this.alto = 64,
    this.tamanoDeTexto = 22,
  });

  final String texto;
  final VoidCallback? alTocar;
  final IconData? icono;

  /// Si es `true` el icono va después del texto; si no, antes.
  final bool iconoAlFinal;

  final double alto;
  final double tamanoDeTexto;

  @override
  Widget build(BuildContext context) {
    final estaApagado = alTocar == null;
    final imagenDelIcono = Icon(
      icono,
      color: Colores.superficie,
      size: tamanoDeTexto + 2,
    );

    return Opacity(
      opacity: estaApagado ? 0.45 : 1,
      child: CajaTocable(
        alTocar: alTocar,
        radio: Radios.boton,
        decoracion: BoxDecoration(
          color: Colores.tinta,
          boxShadow: Sombras.dura(color: Colores.acento),
        ),
        child: Container(
          height: alto,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              if (icono != null && !iconoAlFinal) imagenDelIcono,
              Flexible(
                child: Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Tipografia.titulo(
                    tamanoDeTexto,
                    peso: 700,
                    color: Colores.superficie,
                  ),
                ),
              ),
              if (icono != null && iconoAlFinal) imagenDelIcono,
            ],
          ),
        ),
      ),
    );
  }
}
