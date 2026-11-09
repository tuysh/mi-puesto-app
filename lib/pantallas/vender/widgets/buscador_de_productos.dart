import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_texto.dart';

/// Campo para buscar un producto por su nombre (solo en tablet).
class BuscadorDeProductos extends StatelessWidget {
  const BuscadorDeProductos({super.key, required this.alBuscar});

  /// Recibe el texto cada vez que cambia.
  final ValueChanged<String> alBuscar;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: alBuscar,
      autocorrect: false,
      textInputAction: TextInputAction.search,
      style: Tipografia.texto(16, peso: 600),
      decoration: decoracionDeCampo(sugerencia: 'Buscar producto').copyWith(
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Colores.tintaSuave,
          size: 22,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}
