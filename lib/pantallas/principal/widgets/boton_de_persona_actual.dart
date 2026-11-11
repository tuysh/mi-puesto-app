import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/avatar_de_inicial.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';
import 'package:mi_puesto/pantallas/acceso/cambiar_de_persona.dart';

/// En el riel de tablet: muestra quién está dentro. Al tocarlo se vuelve a
/// "¿Quién vende hoy?" para que entre otra persona.
class BotonDePersonaActual extends StatelessWidget {
  const BotonDePersonaActual({super.key});

  @override
  Widget build(BuildContext context) {
    final perfil = Dependencias.de(context).sesion.perfil;
    if (perfil == null) return const SizedBox.shrink();

    return CajaTocable(
      alTocar: () => cambiarDePersona(context),
      etiqueta: '${perfil.nombre}. Cambiar de persona',
      radio: 16,
      child: SizedBox(
        width: 82,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 3,
          children: [
            AvatarDeInicial(
              inicial: perfil.inicial,
              colores: perfil.colores,
              tamano: 44,
            ),
            Text(
              perfil.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Tipografia.texto(13, peso: 800),
            ),
          ],
        ),
      ),
    );
  }
}
