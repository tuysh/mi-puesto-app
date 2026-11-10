import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/foto_nueva.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/nucleo/widgets/selector_de_segmentos.dart';
import 'package:mi_puesto/pantallas/productos/imagen_elegida.dart';
import 'package:mi_puesto/pantallas/productos/letras_sugeridas.dart';
import 'package:mi_puesto/pantallas/productos/widgets/panel_de_emojis.dart';
import 'package:mi_puesto/pantallas/productos/widgets/panel_de_foto.dart';
import 'package:mi_puesto/pantallas/productos/widgets/panel_de_letras.dart';

/// Las tres maneras de mostrar un producto en los botones.
enum _Modo { emoji, letras, foto }

/// El contenido de "¿Cómo se ve al vender?": una vista previa, los tres
/// modos (Emoji, Letras, Foto), el panel del modo elegido y los botones
/// para terminar.
///
/// Solo queda guardado un modo. Al terminar cierra la hoja o el diálogo que
/// lo contiene y devuelve lo elegido (ver `elegirImagen`).
class SelectorDeImagen extends StatefulWidget {
  const SelectorDeImagen({
    super.key,
    required this.imagenActual,
    required this.nombreDelProducto,
    required this.colores,
  });

  final ImagenElegida imagenActual;
  final String nombreDelProducto;

  /// Los colores de la categoría del producto, para la vista previa.
  final ParDeColores colores;

  @override
  State<SelectorDeImagen> createState() => _EstadoDeSelectorDeImagen();
}

class _EstadoDeSelectorDeImagen extends State<SelectorDeImagen> {
  late _Modo _modo = _modoInicial();
  late String _emoji = widget.imagenActual.emoji;
  late final _letras = TextEditingController(
    text: widget.imagenActual.letras.isEmpty
        ? sugerirLetras(widget.nombreDelProducto)
        : widget.imagenActual.letras,
  );
  late FotoNueva? _fotoNueva = widget.imagenActual.fotoNueva;

  /// `true` mientras la cámara o la galería están abiertas.
  bool _pidiendoFoto = false;
  String? _errorDeFoto;

  /// Empieza en el modo con el que el producto se ve ahora.
  _Modo _modoInicial() {
    final actual = widget.imagenActual;
    if (actual.tieneFoto) return _Modo.foto;
    if (actual.emoji.isEmpty && actual.letras.isNotEmpty) return _Modo.letras;
    return _Modo.emoji;
  }

  bool get _hayFoto =>
      _fotoNueva != null || widget.imagenActual.fotoUrl.isNotEmpty;

  /// Lo que se devuelve con el modo y los datos de este momento; `null`
  /// si todavía falta algo (por ejemplo, no se ha tomado la foto).
  ImagenElegida? get _eleccion {
    switch (_modo) {
      case _Modo.emoji:
        return _emoji.isEmpty ? null : ImagenElegida(emoji: _emoji);
      case _Modo.letras:
        final letras = _letras.text.trim();
        return letras.isEmpty ? null : ImagenElegida(letras: letras);
      case _Modo.foto:
        if (!_hayFoto) return null;
        // El emoji y las letras de antes se conservan: son lo que se ve si
        // la foto no carga.
        return ImagenElegida(
          emoji: widget.imagenActual.emoji,
          letras: widget.imagenActual.letras,
          fotoUrl: _fotoNueva == null ? widget.imagenActual.fotoUrl : '',
          fotoNueva: _fotoNueva,
        );
    }
  }

  @override
  void dispose() {
    _letras.dispose();
    super.dispose();
  }

  Future<void> _pedirFoto(bool conCamara) async {
    final pedirFoto = Dependencias.de(context).pedirFoto;

    setState(() {
      _pidiendoFoto = true;
      _errorDeFoto = null;
    });
    try {
      final foto = await pedirFoto(conCamara: conCamara);
      if (!mounted) return;

      // `null` es que la persona cerró la cámara sin tomar nada.
      if (foto != null) setState(() => _fotoNueva = foto);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorDeFoto = conCamara
            ? 'No se pudo abrir la cámara. Revisa que la aplicación tenga '
                  'permiso para usarla.'
            : 'No se pudo abrir la galería.';
      });
    } finally {
      if (mounted) setState(() => _pidiendoFoto = false);
    }
  }

  void _cancelar() => cerrarPantalla(context);

  /// Cierra el selector y entrega lo elegido a quien lo abrió.
  void _usarEleccion() => Navigator.of(context).pop(_eleccion);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          _construirVistaPrevia(),
          SelectorDeSegmentos<_Modo>(
            opciones: const {
              _Modo.emoji: 'Emoji',
              _Modo.letras: 'Letras',
              _Modo.foto: 'Foto',
            },
            elegida: _modo,
            alElegir: (modo) => setState(() => _modo = modo),
          ),
          // Alto mínimo para que la hoja no brinque al cambiar de modo.
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 178),
            child: switch (_modo) {
              _Modo.emoji => PanelDeEmojis(
                elegido: _emoji,
                alElegir: (emoji) => setState(() => _emoji = emoji),
              ),
              _Modo.letras => PanelDeLetras(
                controlador: _letras,
                // Redibuja para actualizar la vista previa.
                alCambiar: (_) => setState(() {}),
              ),
              _Modo.foto => PanelDeFoto(
                alPedirFoto: _pedirFoto,
                estaOcupado: _pidiendoFoto,
                error: _errorDeFoto,
              ),
            },
          ),
          Row(
            spacing: 10,
            children: [
              BotonDeContorno(texto: 'Cancelar', alTocar: _cancelar),
              Expanded(
                child: BotonPrincipal(
                  texto: switch (_modo) {
                    _Modo.emoji => 'Usar este emoji',
                    _Modo.letras => 'Usar estas letras',
                    _Modo.foto => 'Usar esta foto',
                  },
                  alto: 56,
                  tamanoDeTexto: 20,
                  alTocar: _eleccion == null ? null : _usarEleccion,
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
        _construirMuestra(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text('¿Cómo se ve al vender?', style: Tipografia.titulo(24)),
              Text(
                nombre.isEmpty
                    ? 'Así sale el producto en los botones'
                    : 'Así sale $nombre en los botones',
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

  /// El cuadrito de muestra, según el modo en que se está.
  Widget _construirMuestra() {
    const tamano = 60.0;

    if (_modo == _Modo.foto && !_hayFoto) {
      // Todavía no hay foto: un hueco gris con una cámara.
      return Container(
        width: tamano,
        height: tamano,
        decoration: BoxDecoration(
          color: Colores.superficieHundida,
          borderRadius: BorderRadius.circular(tamano / 3),
        ),
        child: const Icon(
          Icons.photo_camera_outlined,
          color: Colores.tintaSuave,
          size: 26,
        ),
      );
    }

    return switch (_modo) {
      _Modo.emoji => ImagenDeProducto(
        nombre: widget.nombreDelProducto,
        colores: widget.colores,
        emoji: _emoji,
        tamano: tamano,
      ),
      _Modo.letras => ImagenDeProducto(
        nombre: widget.nombreDelProducto,
        colores: widget.colores,
        letras: _letras.text.trim(),
        tamano: tamano,
      ),
      _Modo.foto => ImagenDeProducto(
        nombre: widget.nombreDelProducto,
        colores: widget.colores,
        fotoUrl: widget.imagenActual.fotoUrl,
        fotoLocal: _fotoNueva?.bytes,
        tamano: tamano,
      ),
    };
  }
}
