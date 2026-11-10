import 'package:flutter/foundation.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/foto_nueva.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

enum EstadoDeCarga { cargando, listo, conError }

/// Guarda las categorías y los productos, y avisa cuando cambian.
class ControladorDeCatalogo extends ChangeNotifier {
  ControladorDeCatalogo(this._repositorio);

  final RepositorioDeCatalogo _repositorio;

  EstadoDeCarga _estado = EstadoDeCarga.cargando;
  List<Categoria> _categorias = [];
  List<Producto> _productos = [];

  EstadoDeCarga get estado => _estado;
  List<Categoria> get categorias => _categorias;

  /// Todos los productos, incluidos los ocultos.
  List<Producto> get productos => _productos;

  Future<void> cargar() async {
    _estado = EstadoDeCarga.cargando;
    notifyListeners();

    try {
      _categorias = [...await _repositorio.obtenerCategorias()];
      _productos = [...await _repositorio.obtenerProductos()];
      _estado = EstadoDeCarga.listo;
    } catch (_) {
      _estado = EstadoDeCarga.conError;
    }
    notifyListeners();
  }

  /// La categoría a la que pertenece [producto].
  Categoria categoriaDe(Producto producto) {
    return _categorias.firstWhere((c) => c.id == producto.categoriaId);
  }

  /// Busca un producto por su `id`; devuelve `null` si no existe.
  Producto? buscarProducto(String? id) {
    for (final producto in _productos) {
      if (producto.id == id) return producto;
    }
    return null;
  }

  /// Los productos que se muestran al vender.
  ///
  /// Con [categoriaId] solo devuelve los de esa categoría, y con [busqueda]
  /// solo los que tienen ese texto en el nombre.
  List<Producto> productosALaVenta({
    String? categoriaId,
    String busqueda = '',
  }) {
    final textoBuscado = busqueda.trim().toLowerCase();

    return _productos.where((producto) {
      final esDeLaCategoria =
          categoriaId == null || producto.categoriaId == categoriaId;
      final coincideConLaBusqueda = producto.nombre.toLowerCase().contains(
        textoBuscado,
      );

      return producto.aLaVenta && esDeLaCategoria && coincideConLaBusqueda;
    }).toList();
  }

  /// Cuántos productos (visibles u ocultos) pertenecen a [categoria].
  int cantidadDeProductosEn(Categoria categoria) {
    return _productos.where((p) => p.categoriaId == categoria.id).length;
  }

  /// Guarda una categoría nueva o los cambios de una que ya existía.
  Future<Categoria> guardarCategoria(Categoria categoria) async {
    final guardada = await _repositorio.guardarCategoria(categoria);

    final posicion = _categorias.indexWhere((c) => c.id == guardada.id);
    final yaExistia = posicion != -1;
    if (yaExistia) {
      _categorias[posicion] = guardada;
    } else {
      _categorias.add(guardada);
    }

    notifyListeners();
    return guardada;
  }

  /// Borra [categoria]. Solo se permite si no tiene productos, para que
  /// ningún producto se quede sin categoría.
  Future<void> eliminarCategoria(Categoria categoria) async {
    if (cantidadDeProductosEn(categoria) > 0) {
      throw StateError('No se puede eliminar una categoría con productos.');
    }

    await _repositorio.eliminarCategoria(categoria.id);
    _categorias.removeWhere((c) => c.id == categoria.id);
    notifyListeners();
  }

  /// Guarda un producto nuevo o los cambios de uno que ya existía.
  ///
  /// La foto se guarda aparte, después del producto:
  /// - con [fotoNueva], se sube esa foto;
  /// - si el producto tenía foto y [producto] ya no trae `fotoUrl`, se
  ///   quita (la persona prefirió un emoji o letras).
  ///
  /// Si el producto se guarda pero su foto no, lanza [FotoSinGuardar].
  Future<Producto> guardarProducto(
    Producto producto, {
    FotoNueva? fotoNueva,
  }) async {
    final teniaFoto = buscarProducto(producto.id)?.fotoUrl.isNotEmpty ?? false;

    var guardado = await _repositorio.guardarProducto(producto);
    _ponerProducto(guardado);

    try {
      if (fotoNueva != null) {
        guardado = await _repositorio.subirFotoDeProducto(
          guardado.id,
          fotoNueva,
        );
      } else if (teniaFoto && producto.fotoUrl.isEmpty) {
        guardado = await _repositorio.quitarFotoDeProducto(guardado.id);
      }
    } catch (causa) {
      // El producto sí quedó guardado; lo que falló fue su foto.
      notifyListeners();
      throw FotoSinGuardar(producto: guardado, causa: causa);
    }

    _ponerProducto(guardado);
    notifyListeners();
    return guardado;
  }

  /// Agrega [producto] a la lista o reemplaza al que tenía su mismo `id`.
  void _ponerProducto(Producto producto) {
    final posicion = _productos.indexWhere((p) => p.id == producto.id);
    final yaExistia = posicion != -1;
    if (yaExistia) {
      _productos[posicion] = producto;
    } else {
      _productos.add(producto);
    }
  }
}

/// El producto se guardó bien, pero no se pudo subir (o quitar) su foto.
class FotoSinGuardar implements Exception {
  const FotoSinGuardar({required this.producto, required this.causa});

  /// El producto tal como quedó guardado, todavía con la imagen anterior.
  final Producto producto;

  /// El error original, por si trae una explicación del servidor.
  final Object causa;
}
