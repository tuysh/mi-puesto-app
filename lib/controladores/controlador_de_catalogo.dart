import 'package:flutter/foundation.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
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
  Future<Producto> guardarProducto(Producto producto) async {
    final guardado = await _repositorio.guardarProducto(producto);

    final posicion = _productos.indexWhere((p) => p.id == guardado.id);
    final yaExistia = posicion != -1;
    if (yaExistia) {
      _productos[posicion] = guardado;
    } else {
      _productos.add(guardado);
    }

    notifyListeners();
    return guardado;
  }
}
