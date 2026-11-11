import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/pantallas/productos/emojis_disponibles.dart';
import 'package:mi_puesto/pantallas/productos/widgets/casilla_de_emoji.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_filtro.dart';

/// Los tipos de emoji (Postres, Antojos…) y, debajo, la cuadrícula del
/// tipo elegido para escoger uno tocándolo.
///
/// A propósito NO tiene campo de texto: el emoji solo se elige tocando.
class PanelDeEmojis extends StatefulWidget {
  const PanelDeEmojis({
    super.key,
    required this.elegido,
    required this.alElegir,
  });

  /// El emoji marcado; vacío si todavía no se ha elegido ninguno.
  final String elegido;

  final ValueChanged<String> alElegir;

  @override
  State<PanelDeEmojis> createState() => _EstadoDePanelDeEmojis();
}

class _EstadoDePanelDeEmojis extends State<PanelDeEmojis> {
  late GrupoDeEmojis _grupo = _grupoInicial();

  static const _coloresDeGrupo = ParDeColores(
    fondo: Colores.superficie,
    tinta: Colores.tinta,
  );

  /// Empieza en el grupo que contiene el emoji elegido; si ninguno lo
  /// contiene, en el primero.
  GrupoDeEmojis _grupoInicial() {
    for (final grupo in gruposDeEmojis) {
      if (grupo.emojis.contains(widget.elegido)) return grupo;
    }
    return gruposDeEmojis.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final grupo in gruposDeEmojis)
              BotonDeFiltro(
                texto: grupo.nombre,
                colores: _coloresDeGrupo,
                conBorde: true,
                estaElegido: grupo == _grupo,
                alTocar: () => setState(() => _grupo = grupo),
              ),
          ],
        ),
        ConstrainedBox(
          // Alto mínimo de dos filas, para que el panel no cambie de tamaño
          // al pasar a un grupo con menos emojis.
          constraints: const BoxConstraints(minHeight: 116),
          child: GridView.count(
            crossAxisCount: 6,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            // La cuadrícula mide lo que miden sus casillas y no se desplaza
            // por su cuenta: se desplaza el selector completo.
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final emoji in _grupo.emojis)
                CasillaDeEmoji(
                  emoji: emoji,
                  estaElegido: emoji == widget.elegido,
                  alTocar: () => widget.alElegir(emoji),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
