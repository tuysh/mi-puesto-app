import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/cuadro_de_emoji.dart';
import 'package:mi_puesto/pantallas/productos/widgets/panel_de_emojis.dart';

/// El contenido del selector de emoji de una CATEGORÍA: una vista previa,
/// el panel para elegir tocando y los botones para terminar. (Los
/// productos usan `SelectorDeImagen`, que además ofrece letras y foto.)
///
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
          PanelDeEmojis(
            elegido: _elegido,
            alElegir: (emoji) => setState(() => _elegido = emoji),
          ),
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
}
