import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// La píldora "Cerrar sesión" que va al fondo de "¿Quién vende hoy?".
class BotonDeCerrarSesion extends StatelessWidget {
  const BotonDeCerrarSesion({super.key, required this.alTocar});

  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      radio: Radios.pildora,
      decoracion: BoxDecoration(
        color: Colores.superficie,
        border: Border.all(color: Colores.borde, width: 2),
      ),
      child: Container(
        // 44 de alto para que sea fácil de tocar con el dedo.
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            const Icon(Icons.logout_rounded, color: Colores.tinta, size: 20),
            Text('Cerrar sesión', style: Tipografia.texto(15, peso: 800)),
          ],
        ),
      ),
    );
  }
}
