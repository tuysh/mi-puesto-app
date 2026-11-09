import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';

/// La sección "Historial" (lista de ventas pasadas).
///
/// PENDIENTE: el diseño todavía no incluye esta pantalla. Cuando exista,
/// hará falta un método en `RepositorioDeVentas` para pedir las ventas.
class PantallaDeHistorial extends StatelessWidget {
  const PantallaDeHistorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          const EncabezadoDePantalla(titulo: 'Historial'),
          Text(
            'Aquí aparecerán las ventas anteriores.',
            style: Tipografia.texto(16, peso: 600, color: Colores.tintaSuave),
          ),
        ],
      ),
    );
  }
}
