import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/widgets/aviso_de_pantalla.dart';
import 'package:mi_puesto/pantallas/acceso/cambiar_de_persona.dart';

/// Pantalla 2.2: lo que ve en "Vender" quien solo vende cuando la dueña
/// todavía no abre la caja. No puede abrirla: solo pedir que la abran.
class VistaDeCajaSinAbrir extends StatelessWidget {
  const VistaDeCajaSinAbrir({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = Dependencias.de(context).sesion;
    final nombre = sesion.perfil?.nombre ?? '';
    final duena = sesion.duena?.nombre ?? 'la dueña';

    return AvisoDePantalla(
      icono: Icons.lock_outline_rounded,
      titulo: 'Todavía no se abre la caja',
      explicacion:
          '$nombre, pídele a $duena que abra la caja con su PIN. En '
          'cuanto la abra, puedes empezar a vender.',
      textoDelBoton: 'Cambiar de persona',
      alTocarBoton: () => cambiarDePersona(context),
    );
  }
}
