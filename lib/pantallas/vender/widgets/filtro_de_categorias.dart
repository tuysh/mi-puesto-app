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
    this.enUnaSolaFila = false,
    this.margenLateral = 0,
  });

  final List<Categoria> categorias;

  /// `id` de la categoría elegida; `null` significa "Todo".
  final String? elegida;

  /// Recibe el `id` de la categoría tocada, o `null` al tocar "Todo".
  final ValueChanged<String?> alElegir;

  /// Con `true` (teléfono) los botones van en un solo renglón que se desliza
  /// hacia los lados. Con `false` (tablet) bajan al siguiente renglón cuando
  /// ya no caben.
  final bool enUnaSolaFila;

  /// Espacio a la izquierda y a la derecha de los botones. Va aquí, y no
  /// fuera, para que al deslizar el renglón llegue hasta la orilla de la
  /// pantalla.
  final double margenLateral;

  static const _coloresDeTodo = ParDeColores(
    fondo: Colores.superficie,
    tinta: Colores.tinta,
  );

  @override
  Widget build(BuildContext context) {
    final margen = EdgeInsets.symmetric(horizontal: margenLateral);

    if (enUnaSolaFila) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: margen,
        child: Row(spacing: 8, children: _construirBotones()),
      );
    }

    return Padding(
      padding: margen,
      child: Wrap(spacing: 8, runSpacing: 8, children: _construirBotones()),
    );
  }

  List<Widget> _construirBotones() {
    return [
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
    ];
  }
}
