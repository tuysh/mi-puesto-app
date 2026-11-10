import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/controladores/controlador_de_catalogo.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/banda_de_monto.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_texto.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/pantallas/productos/elegir_imagen.dart';
import 'package:mi_puesto/pantallas/productos/imagen_elegida.dart';
import 'package:mi_puesto/pantallas/productos/widgets/boton_con_lapiz.dart';
import 'package:mi_puesto/pantallas/productos/widgets/selector_de_categoria.dart';

/// El formulario para crear o editar un producto: imagen, nombres,
/// categoría, precio y costo. Mientras se escribe muestra cuánto se gana
/// por pieza.
class FormularioDeProducto extends StatefulWidget {
  const FormularioDeProducto({
    super.key,
    required this.producto,
    required this.alGuardar,
  });

  /// El producto a editar, o uno en blanco (`Producto.nuevo`) para crear.
  final Producto producto;

  /// Se llama después de guardar, con el producto tal como quedó.
  final ValueChanged<Producto> alGuardar;

  @override
  State<FormularioDeProducto> createState() => _EstadoDeFormularioDeProducto();
}

class _EstadoDeFormularioDeProducto extends State<FormularioDeProducto> {
  late final _nombre = TextEditingController(text: widget.producto.nombre);
  late final _nombreCorto = TextEditingController(
    text: widget.producto.nombreCorto,
  );
  late final _precio = TextEditingController(
    text: _textoInicialDeMonto(widget.producto.precio),
  );
  late final _costo = TextEditingController(
    text: _textoInicialDeMonto(widget.producto.costo),
  );

  /// Cómo se ve el producto al vender: emoji, letras o foto.
  late ImagenElegida _imagen = ImagenElegida.de(widget.producto);
  late String _categoriaId = widget.producto.categoriaId;

  bool _guardando = false;

  /// En un producto nuevo los campos de dinero empiezan vacíos, no en "0".
  String _textoInicialDeMonto(Dinero monto) {
    return widget.producto.esNuevo ? '' : formatearMontoEditable(monto);
  }

  /// El precio menos el costo, con lo que esté escrito en este momento.
  Dinero get _gananciaPorPieza {
    final precio = leerDinero(_precio.text) ?? Dinero.cero;
    final costo = leerDinero(_costo.text) ?? Dinero.cero;
    return precio - costo;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _nombreCorto.dispose();
    _precio.dispose();
    _costo.dispose();
    super.dispose();
  }

  /// Redibuja el formulario; se usa cuando cambia el texto de un campo que
  /// afecta a otra parte (el título o la ganancia).
  void _redibujar(String _) => setState(() {});

  Future<void> _cambiarImagen() async {
    final catalogo = Dependencias.de(context).catalogo;
    final categoria = catalogo.categorias.firstWhere(
      (categoria) => categoria.id == _categoriaId,
    );

    final imagen = await elegirImagen(
      context,
      imagenActual: _imagen,
      nombreDelProducto: _nombre.text.trim(),
      colores: categoria.colores,
    );
    if (imagen == null) return;

    setState(() => _imagen = imagen);
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    final nombreCorto = _nombreCorto.text.trim();
    final precio = leerDinero(_precio.text);
    final costo = leerDinero(_costo.text) ?? Dinero.cero;

    if (nombre.isEmpty) {
      mostrarAviso(context, 'Escribe el nombre del producto');
      return;
    }
    if (precio == null) {
      mostrarAviso(context, 'Escribe el precio del producto');
      return;
    }

    // Se parte de `widget.producto` para conservar lo que este formulario
    // no edita (el `id` y si está a la venta).
    final cambiado = widget.producto.copiarCon(
      nombre: nombre,
      nombreCorto: nombreCorto.isEmpty ? nombre : nombreCorto,
      emoji: _imagen.emoji,
      letras: _imagen.letras,
      fotoUrl: _imagen.fotoUrl,
      categoriaId: _categoriaId,
      precio: precio,
      costo: costo,
    );

    final catalogo = Dependencias.de(context).catalogo;
    setState(() => _guardando = true);
    try {
      final guardado = await catalogo.guardarProducto(
        cambiado,
        fotoNueva: _imagen.fotoNueva,
      );
      if (!mounted) return;

      mostrarAviso(context, 'Cambios guardados');
      widget.alGuardar(guardado);
    } on FotoSinGuardar catch (error) {
      // El producto ya existe: se sigue adelante con él para que otro
      // intento no lo cree dos veces.
      if (!mounted) return;

      mostrarAviso(
        context,
        'El producto se guardó, pero su foto no. Intenta ponerla otra vez',
      );
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

  @override
  Widget build(BuildContext context) {
    final catalogo = Dependencias.de(context).catalogo;
    final categoria = catalogo.categorias.firstWhere(
      (categoria) => categoria.id == _categoriaId,
    );
    final nombre = _nombre.text.trim();
    final estiloDeMonto = Tipografia.cifra(20);

    return ColumnaConPie(
      espacio: 14,
      pie: BotonPrincipal(
        texto: 'Guardar cambios',
        alto: 58,
        tamanoDeTexto: 20,
        alTocar: _guardando ? null : _guardar,
      ),
      children: [
        Row(
          spacing: 14,
          children: [
            BotonConLapiz(
              etiqueta: 'Cambiar imagen',
              fondo: categoria.colores.fondo,
              alTocar: _cambiarImagen,
              child: ImagenDeProducto(
                nombre: nombre,
                colores: categoria.colores,
                emoji: _imagen.emoji,
                letras: _imagen.letras,
                fotoUrl: _imagen.fotoUrl,
                fotoLocal: _imagen.fotoNueva?.bytes,
                tamano: BotonConLapiz.tamano,
              ),
            ),
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
        CampoEtiquetado(
          etiqueta: 'Nombre',
          child: CampoDeTexto(controlador: _nombre, alCambiar: _redibujar),
        ),
        CampoEtiquetado(
          etiqueta: 'Nombre corto (en la tesela)',
          child: CampoDeTexto(controlador: _nombreCorto),
        ),
        CampoEtiquetado(
          etiqueta: 'Categoría',
          child: SelectorDeCategoria(
            categorias: catalogo.categorias,
            elegida: _categoriaId,
            alElegir: (id) => setState(() => _categoriaId = id),
          ),
        ),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: CampoEtiquetado(
                etiqueta: 'Precio',
                child: CampoDeTexto(
                  controlador: _precio,
                  prefijo: '\$',
                  esNumero: true,
                  estilo: estiloDeMonto,
                  alCambiar: _redibujar,
                ),
              ),
            ),
            Expanded(
              child: CampoEtiquetado(
                etiqueta: 'Te cuesta',
                child: CampoDeTexto(
                  controlador: _costo,
                  prefijo: '\$',
                  esNumero: true,
                  estilo: estiloDeMonto,
                  alCambiar: _redibujar,
                ),
              ),
            ),
          ],
        ),
        BandaDeMonto(
          etiqueta: 'Ganas por pieza',
          monto: formatearDinero(_gananciaPorPieza),
          tamanoDeMonto: 30,
        ),
        Text(
          'Cambiar el precio no cambia las ventas que ya se hicieron.',
          style: Tipografia.texto(14, peso: 600, color: Colores.tintaSuave),
        ),
      ],
    );
  }
}
