import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/vendedor.dart';
import 'package:mi_puesto/pantallas/vendedores/widgets/tarjeta_de_agregar_persona.dart';
import 'package:mi_puesto/pantallas/vendedores/widgets/tarjeta_de_vendedor.dart';

/// Cuadrícula de dos columnas con una tarjeta por persona y, al final,
/// la tarjeta para agregar a alguien más.
class CuadriculaDeVendedores extends StatelessWidget {
  const CuadriculaDeVendedores({
    super.key,
    required this.vendedores,
    required this.alElegir,
    required this.alAgregar,
  });

  final List<Vendedor> vendedores;
  final ValueChanged<Vendedor> alElegir;
  final VoidCallback alAgregar;

  @override
  Widget build(BuildContext context) {
    return GridView(
      // Deja sitio a las sombras de las tarjetas de la última fila.
      padding: const EdgeInsets.only(bottom: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 168,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      children: [
        for (final vendedor in vendedores)
          TarjetaDeVendedor(
            vendedor: vendedor,
            alTocar: () => alElegir(vendedor),
          ),
        TarjetaDeAgregarPersona(alTocar: alAgregar),
      ],
    );
  }
}
