import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Botón grande con un icono arriba y un texto abajo: "Tomar foto" o
/// "Elegir de la galería".
class BotonDeFoto extends StatelessWidget {
  const BotonDeFoto({
    super.key,
    required this.icono,
    required this.texto,
    required this.alTocar,
  });

  final IconData icono;
  final String texto;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      radio: Radios.boton,
      decoracion: BoxDecoration(
        color: Colores.superficie,
        border: Border.all(color: Colores.tinta, width: 2),
      ),
      child: SizedBox(
        height: 104,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Icon(icono, color: Colores.tinta, size: 30),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: Tipografia.texto(16, peso: 800),
            ),
          ],
        ),
      ),
    );
  }
}
