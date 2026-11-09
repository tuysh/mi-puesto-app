import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_texto.dart';

/// Lista desplegable para elegir la categoría de un producto.
class SelectorDeCategoria extends StatelessWidget {
  const SelectorDeCategoria({
    super.key,
    required this.categorias,
    required this.elegida,
    required this.alElegir,
  });

  final List<Categoria> categorias;

  /// `id` de la categoría elegida.
  final String elegida;

  /// Recibe el `id` de la categoría recién elegida.
  final ValueChanged<String> alElegir;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: elegida,
      onChanged: (categoriaId) {
        if (categoriaId != null) alElegir(categoriaId);
      },
      decoration: decoracionDeCampo(),
      dropdownColor: Colores.superficie,
      style: Tipografia.texto(17, peso: 600),
      items: [
        for (final categoria in categorias)
          DropdownMenuItem(
            value: categoria.id,
            child: Text(categoria.etiqueta),
          ),
      ],
    );
  }
}
