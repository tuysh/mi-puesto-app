import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/borde_punteado.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Tarjeta de borde punteado para dar de alta a otra persona.
class TarjetaDeAgregarPersona extends StatelessWidget {
  const TarjetaDeAgregarPersona({super.key, required this.alTocar});

  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return BordePunteado(
      color: Colores.bordePunteado,
      radio: Radios.tarjetaGrande,
      child: CajaTocable(
        alTocar: alTocar,
        radio: Radios.tarjetaGrande,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            const Icon(Icons.add_rounded, size: 36, color: Colores.tintaSuave),
            Text(
              'Agregar persona',
              style: Tipografia.texto(16, peso: 800, color: Colores.tintaSuave),
            ),
          ],
        ),
      ),
    );
  }
}
