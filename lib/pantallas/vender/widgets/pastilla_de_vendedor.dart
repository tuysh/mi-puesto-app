import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/avatar_de_inicial.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';
import 'package:mi_puesto/pantallas/vendedores/pantalla_quien_vende.dart';

/// Píldora con la inicial y el nombre de quien vende. Al tocarla se abre
/// "¿Quién vende hoy?" para cambiar de persona.
class PastillaDeVendedor extends StatelessWidget {
  const PastillaDeVendedor({super.key});

  @override
  Widget build(BuildContext context) {
    final vendedor = Dependencias.de(context).sesion.vendedor;
    if (vendedor == null) return const SizedBox.shrink();

    return CajaTocable(
      alTocar: () => abrirPantalla(context, const PantallaQuienVende()),
      etiqueta: '${vendedor.nombre}, cambiar de persona',
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
              inicial: vendedor.inicial,
              colores: const ParDeColores(
                fondo: Colores.acentoSuave,
                tinta: Colores.tinta,
              ),
              tamano: 32,
            ),
            Text(vendedor.nombre, style: Tipografia.texto(15, peso: 800)),
          ],
        ),
      ),
    );
  }
}
