import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';

/// Mensaje centrado para cuando los datos no se pudieron cargar, con un
/// botón para intentarlo otra vez.
class MensajeDeError extends StatelessWidget {
  const MensajeDeError({super.key, required this.alReintentar});

  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(
              'No se pudo cargar la información',
              textAlign: TextAlign.center,
              style: Tipografia.texto(17, color: Colores.tintaSuave),
            ),
            BotonDeContorno(
              texto: 'Intentar otra vez',
              icono: Icons.refresh_rounded,
              alTocar: alReintentar,
            ),
          ],
        ),
      ),
    );
  }
}
