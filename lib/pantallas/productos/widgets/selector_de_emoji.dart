import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/cuadro_de_emoji.dart';
import 'package:mi_puesto/pantallas/productos/emojis_disponibles.dart';
import 'package:mi_puesto/pantallas/productos/widgets/casilla_de_emoji.dart';
import 'package:mi_puesto/pantallas/vender/widgets/boton_de_filtro.dart';

/// El contenido del selector de emoji: una vista previa, los tipos de
/// emoji, la cuadrícula para elegir tocando y los botones para terminar.
///
/// A propósito NO tiene campo de texto: el emoji solo se elige tocando.
/// Al terminar cierra la hoja o el diálogo que lo contiene y devuelve el
/// emoji elegido (ver `elegirEmoji`).
class SelectorDeEmoji extends StatefulWidget {
  const SelectorDeEmoji({
    super.key,
    required this.emojiActual,
    required this.nombreDelProducto,
    required this.fondo,
  });

  final String emojiActual;
  final String nombreDelProducto;

  /// Color de la categoría del producto, para la vista previa.
  final Color fondo;

  @override
  State<SelectorDeEmoji> createState() => _EstadoDeSelectorDeEmoji();
}

class _EstadoDeSelectorDeEmoji extends State<SelectorDeEmoji> {
  late String _elegido = widget.emojiActual;
  late GrupoDeEmojis _grupo = _grupoInicial();

  static const _coloresDeGrupo = ParDeColores(
    fondo: Colores.superficie,
    tinta: Colores.tinta,
  );

  /// Empieza en el grupo que contiene el emoji actual; si ninguno lo
  /// contiene, en el primero.
  GrupoDeEmojis _grupoInicial() {
    for (final grupo in gruposDeEmojis) {
      if (grupo.emojis.contains(widget.emojiActual)) return grupo;
    }
    return gruposDeEmojis.first;
  }

  void _cancelar() => cerrarPantalla(context);

  /// Cierra el selector y entrega el emoji elegido a quien lo abrió.
  void _usarElegido() => Navigator.of(context).pop(_elegido);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          _construirVistaPrevia(),
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
          _construirCuadricula(),
          Row(
            spacing: 10,
            children: [
              BotonDeContorno(texto: 'Cancelar', alTocar: _cancelar),
              Expanded(
                child: BotonPrincipal(
                  texto: 'Usar este emoji',
                  alto: 56,
                  tamanoDeTexto: 20,
                  alTocar: _usarElegido,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirVistaPrevia() {
    final nombre = widget.nombreDelProducto;

    return Row(
      spacing: 14,
      children: [
        CuadroDeEmoji(emoji: _elegido, fondo: widget.fondo, tamano: 60),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text('Elige un emoji', style: Tipografia.titulo(24)),
              Text(
                nombre.isEmpty
                    ? 'Así se verá el producto al vender'
                    : 'Así se verá $nombre al vender',
                style: Tipografia.texto(
                  15,
                  peso: 600,
                  color: Colores.tintaSuave,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirCuadricula() {
    return ConstrainedBox(
      // Alto mínimo de dos filas, para que el selector no cambie de tamaño
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
              estaElegido: emoji == _elegido,
              alTocar: () => setState(() => _elegido = emoji),
            ),
        ],
      ),
    );
  }
}
