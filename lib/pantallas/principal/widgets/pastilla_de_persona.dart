import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/avatar_de_inicial.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';
import 'package:mi_puesto/pantallas/acceso/cambiar_de_persona.dart';

/// Píldora con la inicial y el nombre de quien está dentro. Al tocarla se
/// vuelve a "¿Quién vende hoy?" para que entre otra persona.
class PastillaDePersona extends StatelessWidget {
  const PastillaDePersona({super.key});

  @override
  Widget build(BuildContext context) {
    final perfil = Dependencias.de(context).sesion.perfil;
    if (perfil == null) return const SizedBox.shrink();

    return CajaTocable(
      alTocar: () => cambiarDePersona(context),
      etiqueta: '${perfil.nombre}. Cambiar de persona',
      radio: Radios.pildora,
      decoracion: BoxDecoration(
        color: Colores.superficie,
        border: Border.all(color: Colores.borde, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 4, 14, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            AvatarDeInicial(
              inicial: perfil.inicial,
              colores: perfil.colores,
              tamano: 32,
            ),
            Text(perfil.nombre, style: Tipografia.texto(15, peso: 800)),
          ],
        ),
      ),
    );
  }
}
