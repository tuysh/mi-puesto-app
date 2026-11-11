import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_texto.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/dialogo_de_confirmacion.dart';
import 'package:mi_puesto/nucleo/widgets/dialogo_de_texto.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/fila_de_lista_vacia.dart';
import 'package:mi_puesto/nucleo/widgets/lista_en_tarjeta.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/selector_de_segmentos.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/categorias/grupo_de_categorias.dart';
import 'package:mi_puesto/pantallas/categorias/widgets/fila_de_categoria.dart';

/// Pantalla 5.5: las categorías de productos y las de gastos, en dos
/// pestañas. Aquí se agregan, se renombran y se eliminan.
///
/// El color no se elige: el servidor reparte el pastel que sigue.
class PantallaDeCategorias extends StatefulWidget {
  const PantallaDeCategorias({
    super.key,
    this.grupoInicial = GrupoDeCategorias.deProductos,
  });

  /// La pestaña con la que abre.
  final GrupoDeCategorias grupoInicial;

  @override
  State<PantallaDeCategorias> createState() => _EstadoDePantallaDeCategorias();
}

class _EstadoDePantallaDeCategorias extends State<PantallaDeCategorias> {
  /// Lo más largo que puede ser el nombre de una categoría.
  static const _largoMaximoDelNombre = 30;

  late GrupoDeCategorias _grupo = widget.grupoInicial;

  final _nombreNuevo = TextEditingController();

  /// Cambia cada vez que se agrega, renombra o elimina una categoría, para
  /// que la lista se pida otra vez.
  int _version = 0;

  @override
  void dispose() {
    _nombreNuevo.dispose();
    super.dispose();
  }

  /// El repositorio de la pestaña en la que se está.
  RepositorioDeCategorias get _repositorio {
    final conexiones = Dependencias.de(context).conexiones;
    return _grupo == GrupoDeCategorias.deProductos
        ? conexiones.categoriasDeProductos
        : conexiones.categoriasDeGastos;
  }

  /// Hace un cambio en el servidor y vuelve a pedir la lista. Si falla,
  /// avisa con [siFalla].
  Future<void> _cambiar(
    Future<void> Function() cambio, {
    required String siFalla,
  }) async {
    final catalogo = Dependencias.de(context).catalogo;
    final sonDeProductos = _grupo == GrupoDeCategorias.deProductos;

    try {
      await cambio();
      // "Vender" pinta los productos con el color de su categoría.
      if (sonDeProductos) await catalogo.actualizar();
      if (mounted) setState(() => _version++);
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(context, error, siNoHayExplicacion: siFalla);
      }
    }
  }

  Future<void> _agregar() async {
    final nombre = _nombreNuevo.text.trim();
    if (nombre.isEmpty) {
      mostrarAviso(context, 'Escribe el nombre de la categoría');
      return;
    }

    await _cambiar(() async {
      await _repositorio.crearCategoria(nombre);
      _nombreNuevo.clear();
    }, siFalla: 'No se pudo agregar la categoría');
  }

  Future<void> _renombrar(Categoria categoria) async {
    final nombre = await pedirTexto(
      context,
      titulo: 'Cambiar nombre',
      valorInicial: categoria.nombre,
      maximoDeLetras: _largoMaximoDelNombre,
    );
    if (nombre == null || nombre == categoria.nombre) return;

    await _cambiar(
      () => _repositorio.renombrarCategoria(categoria.id, nombre),
      siFalla: 'No se pudo cambiar el nombre',
    );
  }

  Future<void> _eliminar(Categoria categoria) async {
    final confirmo = await pedirConfirmacion(
      context,
      titulo: '¿Eliminar ${categoria.nombre}?',
      mensaje: _grupo.queLesPasaAlEliminar,
      textoDeConfirmar: 'Eliminar',
    );
    if (!confirmo) return;

    await _cambiar(
      () => _repositorio.eliminarCategoria(categoria.id),
      siFalla: 'No se pudo eliminar la categoría',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MarcoDePantalla(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          const EncabezadoConVolver(titulo: 'Categorías'),
          SelectorDeSegmentos<GrupoDeCategorias>.grande(
            opciones: {
              for (final grupo in GrupoDeCategorias.values)
                grupo: grupo.etiqueta,
            },
            elegida: _grupo,
            alElegir: (grupo) => setState(() => _grupo = grupo),
          ),
          TextoDeAyuda(_grupo.ayuda, peso: 700),
          Expanded(
            child: CargadorDeFuturo<List<Categoria>>(
              // Con otra llave se vuelve a pedir: otra pestaña u otra
              // versión.
              key: ValueKey((_grupo, _version)),
              cargar: _repositorio.obtenerCategorias,
              construir: (context, categorias) => SingleChildScrollView(
                child: ListaEnTarjeta(
                  children: [
                    if (categorias.isEmpty)
                      const FilaDeListaVacia('Todavía no hay categorías.'),
                    for (final categoria in categorias)
                      FilaDeCategoria(
                        categoria: categoria,
                        textoDeUsos: _grupo.textoDeUsos(categoria.usos),
                        alRenombrar: () => _renombrar(categoria),
                        alEliminar: () => _eliminar(categoria),
                      ),
                  ],
                ),
              ),
            ),
          ),
          CampoEtiquetado(
            etiqueta: 'Nueva categoría',
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: CampoDeTexto(
                    controlador: _nombreNuevo,
                    sugerencia: _grupo.ejemplo,
                    maximoDeLetras: _largoMaximoDelNombre,
                    alEnviar: _agregar,
                  ),
                ),
                BotonDeContorno(texto: 'Agregar', alTocar: _agregar),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
