import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/avatar_de_inicial.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';
import 'package:mi_puesto/pantallas/vendedores/pantalla_quien_vende.dart';

/// En el riel de tablet: muestra quién está vendiendo. Al tocarlo se puede
/// cambiar de persona.
class BotonDeVendedorActual extends StatelessWidget {
  const BotonDeVendedorActual({super.key});

  @override
  Widget build(BuildContext context) {
    final vendedor = Dependencias.de(context).sesion.vendedor;
    if (vendedor == null) return const SizedBox.shrink();

    return CajaTocable(
      alTocar: () => abrirPantalla(context, const PantallaQuienVende()),
      etiqueta: '${vendedor.nombre}, cambiar de persona',
      radio: 16,
      child: SizedBox(
        width: 82,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 3,
          children: [
            AvatarDeInicial(
              inicial: vendedor.inicial,
              colores: vendedor.colores,
              tamano: 44,
            ),
            Text(
              vendedor.nombre,
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
