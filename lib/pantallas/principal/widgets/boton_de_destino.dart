import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';
import 'package:mi_puesto/pantallas/principal/destino.dart';

/// Un botón del menú de navegación: icono arriba y nombre abajo.
/// El de la sección actual se pinta con fondo rosa.
class BotonDeDestino extends StatelessWidget {
  const BotonDeDestino({
    super.key,
    required this.destino,
    required this.estaElegido,
    required this.alTocar,
    this.ancho = 72,
    this.tamanoDeIcono = 24,
    this.tamanoDeTexto = 12,
  });

  final Destino destino;
  final bool estaElegido;
  final VoidCallback alTocar;
  final double ancho;
  final double tamanoDeIcono;
  final double tamanoDeTexto;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      radio: 16,
      decoracion: BoxDecoration(
        color: estaElegido ? Colores.acentoSuave : null,
      ),
      child: Container(
        width: ancho,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            Icon(destino.icono, size: tamanoDeIcono, color: Colores.tinta),
            Text(
              destino.etiqueta,
              maxLines: 1,
              style: Tipografia.texto(tamanoDeTexto, peso: 800),
            ),
          ],
        ),
      ),
    );
  }
}
