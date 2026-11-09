import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Un renglón del menú "Más": icono, texto y una flechita.
class OpcionDeMenu extends StatelessWidget {
  const OpcionDeMenu({
    super.key,
    required this.icono,
    required this.texto,
    required this.alTocar,
  });

  final IconData icono;
  final String texto;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      radio: Radios.tarjeta,
      decoracion: BoxDecoration(
        color: Colores.superficie,
        border: Border.all(color: Colores.borde, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          spacing: 14,
          children: [
            Icon(icono, color: Colores.tinta, size: 26),
            Expanded(
              child: Text(texto, style: Tipografia.texto(17, peso: 800)),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colores.tintaSuave,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
