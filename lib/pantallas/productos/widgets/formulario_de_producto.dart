import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/controladores/controlador_de_catalogo.dart';
import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/modelos/presentacion.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_texto.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/dialogo_de_confirmacion.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/nucleo/widgets/selector_de_segmentos.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/categorias/pantalla_de_categorias.dart';
import 'package:mi_puesto/pantallas/productos/elegir_imagen.dart';
import 'package:mi_puesto/pantallas/productos/imagen_elegida.dart';
import 'package:mi_puesto/pantallas/productos/tamano_en_edicion.dart';
import 'package:mi_puesto/pantallas/productos/widgets/boton_con_lapiz.dart';
import 'package:mi_puesto/pantallas/productos/widgets/editor_de_tamanos.dart';
import 'package:mi_puesto/pantallas/productos/widgets/selector_de_categoria.dart';

/// Las dos maneras de vender un producto.
enum _ComoSeVende { aUnPrecio, porTamanos }

/// El formulario para crear o editar un producto: su imagen, su nombre, su
/// categoría y cómo se vende (a un solo precio, o en varios tamaños cada
/// uno con el suyo).
///
/// "Hay hoy" no va aquí: se prende y se apaga desde la lista de productos.
class FormularioDeProducto extends StatefulWidget {
  const FormularioDeProducto({
    super.key,
    required this.producto,
    required this.alGuardar,
    required this.alDesactivar,
    this.conTitulo = false,
  });

  /// El producto a editar, o uno en blanco (`Producto.nuevo`) para crear.
  final Producto producto;

  /// Se llama después de guardar, con el producto tal como quedó.
  final ValueChanged<Producto> alGuardar;

  /// Se llama después de desactivar el producto.
  final VoidCallback alDesactivar;

  /// Con `true` (tablet) el nombre del producto va como título junto a la
  /// imagen. Con `false` (teléfono) el título ya lo pone la pantalla.
  final bool conTitulo;

  @override
  State<FormularioDeProducto> createState() => _EstadoDeFormularioDeProducto();
}

class _EstadoDeFormularioDeProducto extends State<FormularioDeProducto> {
  late final _nombre = TextEditingController(text: widget.producto.nombre);
  late final _precio = TextEditingController(text: _precioInicial());

  /// Cómo se ve el producto al vender: emoji, letras o foto.
  late ImagenElegida _imagen = ImagenElegida.de(widget.producto);
  late String? _categoriaId = widget.producto.categoriaId;

  late _ComoSeVende _comoSeVende = widget.producto.tieneTamanos
      ? _ComoSeVende.porTamanos
      : _ComoSeVende.aUnPrecio;

  /// Los renglones de tamaños que se están editando.
  late final List<TamanoEnEdicion> _tamanos = [
    for (final presentacion in widget.producto.presentaciones)
      TamanoEnEdicion.de(presentacion),
  ];

  bool _guardando = false;

  /// En un producto nuevo (o con tamaños) el precio empieza vacío.
  String _precioInicial() {
    final precio = widget.producto.precio;
    if (widget.producto.esNuevo || precio == null) return '';
    return formatearMontoEditable(precio);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    for (final tamano in _tamanos) {
      tamano.liberar();
    }
    super.dispose();
  }

  void _elegirComoSeVende(_ComoSeVende comoSeVende) {
    setState(() {
      _comoSeVende = comoSeVende;
      // Al pasar a tamaños por primera vez se ofrecen dos renglones.
      if (comoSeVende == _ComoSeVende.porTamanos && _tamanos.isEmpty) {
        _tamanos.addAll([TamanoEnEdicion.nuevo(), TamanoEnEdicion.nuevo()]);
      }
    });
  }

  void _quitarTamano(TamanoEnEdicion tamano) {
    setState(() => _tamanos.remove(tamano));
    tamano.liberar();
  }

  Future<void> _cambiarImagen() async {
    final catalogo = Dependencias.de(context).catalogo;

    final imagen = await elegirImagen(
      context,
      imagenActual: _imagen,
      nombreDelProducto: _nombre.text.trim(),
      colores: catalogo.coloresDe(_categoriaId),
    );
    if (imagen == null) return;

    setState(() => _imagen = imagen);
  }

  /// Arma el producto con lo que hay escrito. Si falta algo, avisa y
  /// devuelve `null`.
  Producto? _leerProducto() {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      mostrarAviso(context, 'Escribe el nombre del producto');
      return null;
    }

    final precio = leerDinero(_precio.text);
    final tamanos = <Presentacion>[];
    if (_comoSeVende == _ComoSeVende.aUnPrecio) {
      if (precio == null) {
        mostrarAviso(context, 'Escribe el precio del producto');
        return null;
      }
    } else {
      for (final renglon in _tamanos) {
        final tamano = renglon.leer();
        if (tamano == null) {
          mostrarAviso(context, 'Cada tamaño necesita su nombre y su precio');
          return null;
        }
        tamanos.add(tamano);
      }
      if (tamanos.isEmpty) {
        mostrarAviso(context, 'Agrega al menos un tamaño');
        return null;
      }
    }

    return Producto(
      id: widget.producto.id,
      nombre: nombre,
      categoriaId: _categoriaId,
      // Un precio o tamaños, nunca los dos.
      precio: tamanos.isEmpty ? precio : null,
      presentaciones: tamanos,
      representacion: _imagen.representacion,
      emoji: _imagen.emoji,
      letras: _imagen.letras,
      imagenUrl: _imagen.fotoUrl,
      disponible: widget.producto.disponible,
    );
  }

  Future<void> _guardar() async {
    final producto = _leerProducto();
    if (producto == null) return;

    final catalogo = Dependencias.de(context).catalogo;
    setState(() => _guardando = true);
    try {
      final guardado = await catalogo.guardarProducto(
        producto,
        fotoNueva: _imagen.fotoNueva,
      );
      if (!mounted) return;

      // La foto ya está en el servidor: de aquí en adelante vale la
      // dirección que respondió, no la foto local ni la de antes.
      setState(() => _imagen = ImagenElegida.de(guardado));
      mostrarAviso(context, 'Cambios guardados');
      widget.alGuardar(guardado);
    } on FotoSinGuardar catch (error) {
      // El producto ya existe: se sigue adelante con él para que otro
      // intento no lo cree dos veces.
      if (!mounted) return;

      // Se dice por qué, si el servidor lo explicó ("La foto pesa más de
      // 10 MB.", "Las fotos no están disponibles por ahora.").
      final causa = error.causa;
      final explicacion = causa is ErrorDelServidor
          ? causa.mensaje
          : 'Intenta ponerla otra vez';
      debugPrint('No se pudo guardar la foto: $causa');
      mostrarAviso(
        context,
        'El producto se guardó, pero su foto no. $explicacion',
      );
      setState(() => _imagen = ImagenElegida.de(error.producto));
      widget.alGuardar(error.producto);
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo guardar el producto',
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _desactivar() async {
    final catalogo = Dependencias.de(context).catalogo;

    final confirmo = await pedirConfirmacion(
      context,
      titulo: '¿Desactivar ${widget.producto.nombre}?',
      mensaje:
          'Ya no va a salir al vender. Las ventas que ya se hicieron no '
          'cambian.',
      textoDeConfirmar: 'Desactivar',
    );
    if (!confirmo) return;

    try {
      await catalogo.desactivarProducto(widget.producto);
      if (mounted) widget.alDesactivar();
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo desactivar el producto',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogo = Dependencias.de(context).catalogo;
    final esNuevo = widget.producto.esNuevo;

    return ColumnaConPie(
      espacio: 14,
      pie: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          BotonPrincipal(
            texto: esNuevo ? 'Guardar producto' : 'Guardar cambios',
            icono: Icons.check_rounded,
            iconoAlFinal: true,
            alTocar: _guardando ? null : _guardar,
          ),
          if (!esNuevo)
            Center(
              child: BotonDeEnlace(
                texto: 'Desactivar producto',
                alTocar: _desactivar,
              ),
            ),
        ],
      ),
      children: [
        _construirImagenYNombre(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Categoría',
                    style: Tipografia.texto(15, peso: 800),
                  ),
                ),
                BotonDeEnlace(
                  texto: 'Nueva categoría',
                  alTocar: () =>
                      abrirPantalla(context, const PantallaDeCategorias()),
                ),
              ],
            ),
            // Se redibuja si cambian las categorías (al volver de crear
            // una).
            ListenableBuilder(
              listenable: catalogo,
              builder: (context, _) => SelectorDeCategoria(
                categorias: catalogo.categorias,
                elegida: _categoriaId,
                alElegir: (id) => setState(() => _categoriaId = id),
              ),
            ),
          ],
        ),
        CampoEtiquetado(
          etiqueta: '¿Cómo se vende?',
          child: SelectorDeSegmentos<_ComoSeVende>.grande(
            opciones: const {
              _ComoSeVende.aUnPrecio: 'Un solo precio',
              _ComoSeVende.porTamanos: 'Varios tamaños',
            },
            elegida: _comoSeVende,
            alElegir: _elegirComoSeVende,
          ),
        ),
        if (_comoSeVende == _ComoSeVende.aUnPrecio)
          CampoEtiquetado(
            etiqueta: 'Precio',
            child: CampoDeTexto(
              controlador: _precio,
              prefijo: '\$',
              esNumero: true,
              estilo: Tipografia.cifra(20),
            ),
          )
        else
          CampoEtiquetado(
            etiqueta: 'Tamaños y precios',
            child: EditorDeTamanos(
              tamanos: _tamanos,
              alAgregar: () =>
                  setState(() => _tamanos.add(TamanoEnEdicion.nuevo())),
              alQuitar: _quitarTamano,
            ),
          ),
        const TextoDeAyuda(
          'Cambiar el precio o desactivar el producto no cambia las ventas '
          'que ya se hicieron.',
        ),
      ],
    );
  }

  /// La imagen del producto (que se toca para cambiarla) y su nombre.
  Widget _construirImagenYNombre() {
    final catalogo = Dependencias.de(context).catalogo;
    final colores = catalogo.coloresDe(_categoriaId);
    final nombre = _nombre.text.trim();
    final tamanoDeImagen = widget.conTitulo ? 64.0 : 58.0;

    final imagen = BotonConLapiz(
      etiqueta: 'Cambiar imagen',
      fondo: colores.fondo,
      tamano: tamanoDeImagen,
      alTocar: _cambiarImagen,
      child: ImagenDeProducto(
        nombre: nombre,
        colores: colores,
        emoji: _imagen.emoji,
        letras: _imagen.letras,
        fotoUrl: _imagen.fotoUrl,
        fotoLocal: _imagen.fotoNueva?.bytes,
        tamano: tamanoDeImagen,
      ),
    );
    final campoDeNombre = CampoEtiquetado(
      etiqueta: 'Nombre',
      child: CampoDeTexto(
        controlador: _nombre,
        // Redibuja para actualizar el título y la inicial de la imagen.
        alCambiar: (_) => setState(() {}),
      ),
    );

    if (!widget.conTitulo) {
      return Row(
        // "end" alinea la imagen con el campo, no con su etiqueta.
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 14,
        children: [
          imagen,
          Expanded(child: campoDeNombre),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Row(
          spacing: 14,
          children: [
            imagen,
            Expanded(
              child: Text(
                nombre.isEmpty ? 'Nuevo producto' : nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Tipografia.titulo(24),
              ),
            ),
          ],
        ),
        campoDeNombre,
      ],
    );
  }
}
