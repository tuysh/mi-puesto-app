import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_texto.dart';

/// Lista desplegable para elegir la categoría de un producto. La primera
/// opción es "Sin categoría".
class SelectorDeCategoria extends StatelessWidget {
  const SelectorDeCategoria({
    super.key,
    required this.categorias,
    required this.elegida,
    required this.alElegir,
  });

  final List<Categoria> categorias;

  /// `id` de la categoría elegida; `null` si el producto no tiene.
  final String? elegida;

  /// Recibe el `id` de la categoría recién elegida, o `null` al elegir
  /// "Sin categoría".
  final ValueChanged<String?> alElegir;

  /// Lo que vale la opción "Sin categoría" dentro de la lista. La lista
  /// desplegable no distingue entre "se eligió `null`" y "no se eligió
  /// nada", así que se usa un texto que ningún `id` puede tener.
  static const _sinCategoria = '';

  @override
  Widget build(BuildContext context) {
    // Si la categoría elegida ya no existe (la acaban de eliminar), se
    // muestra "Sin categoría".
    final existe = categorias.any((categoria) => categoria.id == elegida);

    return DropdownButtonFormField<String>(
      // Con otra llave la lista se crea de nuevo: hace falta cuando cambia
      // la elegida desde fuera o cambian las categorías.
      key: ValueKey((elegida, categorias.length)),
      initialValue: existe ? elegida : _sinCategoria,
      onChanged: (valor) {
        alElegir(valor == _sinCategoria ? null : valor);
      },
      decoration: decoracionDeCampo(),
      dropdownColor: Colores.superficie,
      style: Tipografia.texto(17, peso: 600),
      items: [
        const DropdownMenuItem(
          value: _sinCategoria,
          child: Text('Sin categoría'),
        ),
        for (final categoria in categorias)
          DropdownMenuItem(value: categoria.id, child: Text(categoria.nombre)),
      ],
    );
  }
}
