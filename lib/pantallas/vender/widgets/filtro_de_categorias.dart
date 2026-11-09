import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/pantallas/vender/widgets/boton_de_filtro.dart';

/// La fila de botones para ver una sola categoría, o "Todo".
class FiltroDeCategorias extends StatelessWidget {
  const FiltroDeCategorias({
    super.key,
    required this.categorias,
    required this.elegida,
    required this.alElegir,
  });

  final List<Categoria> categorias;

  /// `id` de la categoría elegida; `null` significa "Todo".
  final String? elegida;

  /// Recibe el `id` de la categoría tocada, o `null` al tocar "Todo".
  final ValueChanged<String?> alElegir;

  static const _coloresDeTodo = ParDeColores(
    fondo: Colores.superficie,
    tinta: Colores.tinta,
  );

  @override
  Widget build(BuildContext context) {
    // Wrap acomoda los botones en fila y baja al siguiente renglón
    // cuando ya no caben.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        BotonDeFiltro(
          texto: 'Todo',
          colores: _coloresDeTodo,
          conBorde: true,
          estaElegido: elegida == null,
          alTocar: () => alElegir(null),
        ),
        for (final categoria in categorias)
          BotonDeFiltro(
            texto: categoria.etiqueta,
            colores: categoria.colores,
            estaElegido: elegida == categoria.id,
            alTocar: () => alElegir(categoria.id),
          ),
      ],
    );
  }
}
