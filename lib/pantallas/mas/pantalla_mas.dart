import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';
import 'package:mi_puesto/pantallas/mas/widgets/opcion_de_menu.dart';
import 'package:mi_puesto/pantallas/principal/destino.dart';
import 'package:mi_puesto/pantallas/vendedores/pantalla_quien_vende.dart';

/// La sección "Más" del teléfono: lleva a lo que no cabe en la barra.
class PantallaMas extends StatelessWidget {
  const PantallaMas({super.key, required this.alElegir});

  /// Se llama con la sección a la que la persona quiere ir.
  final ValueChanged<Destino> alElegir;

  @override
  Widget build(BuildContext context) {
    return AnchoMaximo(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
        children: [
          const EncabezadoDePantalla(titulo: 'Más'),
          const SizedBox(height: 14),
          OpcionDeMenu(
            icono: Destino.productos.icono,
            texto: Destino.productos.etiqueta,
            alTocar: () => alElegir(Destino.productos),
          ),
          const SizedBox(height: 10),
          OpcionDeMenu(
            icono: Destino.historial.icono,
            texto: Destino.historial.etiqueta,
            alTocar: () => alElegir(Destino.historial),
          ),
          const SizedBox(height: 10),
          OpcionDeMenu(
            icono: Icons.people_outline_rounded,
            texto: 'Cambiar de persona',
            alTocar: () => abrirPantalla(context, const PantallaQuienVende()),
          ),
        ],
      ),
    );
  }
}
