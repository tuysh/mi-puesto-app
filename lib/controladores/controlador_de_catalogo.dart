import 'package:flutter/foundation.dart';
import 'package:mi_puesto/controladores/estado_de_carga.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/foto_nueva.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Guarda las categorías y los productos activos, y avisa cuando cambian.
class ControladorDeCatalogo extends ChangeNotifier {
  ControladorDeCatalogo(this._repositorio);

  final RepositorioDeCatalogo _repositorio;

  EstadoDeCarga _estado = EstadoDeCarga.cargando;
  List<Categoria> _categorias = [];
  List<Producto> _productos = [];
  Object? _error;

  EstadoDeCarga get estado => _estado;
  List<Categoria> get categorias => _categorias;

  /// Los productos activos, haya o no haya hoy.
  List<Producto> get productos => _productos;

  /// Lo que falló la última vez que se cargó; `null` si salió bien.
  Object? get error => _error;

  /// Pide el catálogo mostrando la rueda de carga.
  Future<void> cargar() async {
    _estado = EstadoDeCarga.cargando;
    notifyListeners();
    await actualizar();
  }

  /// Vuelve a pedir el catálogo sin mostrar la rueda de carga: después de
  /// cambiar las categorías, por ejemplo.
  Future<void> actualizar() async {
    try {
      final catalogo = await _repositorio.obtenerCatalogo();
      _categorias = [...catalogo.categorias];
      _productos = [...catalogo.productos];
      _estado = EstadoDeCarga.listo;
      _error = null;
    } catch (error) {
      _estado = EstadoDeCarga.conError;
      _error = error;
    }
    notifyListeners();
  }

  /// La categoría de [producto]; `null` si no tiene.
  Categoria? categoriaDe(Producto producto) {
    return buscarCategoria(producto.categoriaId);
  }

  /// Busca una categoría por su `id`; devuelve `null` si no existe.
  Categoria? buscarCategoria(String? id) {
    for (final categoria in _categorias) {
      if (categoria.id == id) return categoria;
    }
    return null;
  }

  /// Los colores con los que se pinta lo que es de la categoría
  /// [categoriaId]. Lo que no tiene categoría va en gris.
  ParDeColores coloresDe(String? categoriaId) {
    return buscarCategoria(categoriaId)?.colores ?? Colores.sinCategoria;
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
  List<Producto> productosParaVender({
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

      return esDeLaCategoria && coincideConLaBusqueda;
    }).toList();
  }

  /// Cuántos productos tienen "Hay hoy" encendido.
  int get cuantosHayHoy {
    return _productos.where((producto) => producto.disponible).length;
  }

  /// Guarda un producto nuevo o los cambios de uno que ya existía.
  ///
  /// La foto se guarda aparte, después del producto:
  /// - con [fotoNueva], se sube esa foto;
  /// - si el producto tenía foto y [producto] ya no se pinta con imagen,
  ///   se quita (la persona prefirió un emoji o letras).
  ///
  /// Si el producto se guarda pero su foto no, lanza [FotoSinGuardar].
  Future<Producto> guardarProducto(
    Producto producto, {
    FotoNueva? fotoNueva,
  }) async {
    final anterior = buscarProducto(producto.id);
    final teniaFoto = anterior?.representacion == Representacion.imagen;
    final yaNoQuiereFoto = producto.representacion != Representacion.imagen;

    var guardado = await _repositorio.guardarProducto(producto);
    _ponerProducto(guardado);

    try {
      if (fotoNueva != null) {
        guardado = await _repositorio.subirFotoDeProducto(
          guardado.id,
          fotoNueva,
        );
      } else if (teniaFoto && yaNoQuiereFoto) {
        await _repositorio.quitarFotoDeProducto(guardado.id);
        // Al quitar la foto el servidor elige emoji o letras por su
        // cuenta; se vuelve a guardar para que quede lo que se eligió.
        guardado = await _repositorio.guardarProducto(
          producto.copiarCon(id: guardado.id),
        );
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

  /// Prende o apaga "Hay hoy" de [producto].
  Future<void> cambiarDisponibilidad(Producto producto, bool disponible) async {
    final cambiado = await _repositorio.cambiarDisponibilidad(
      producto.id,
      disponible,
    );
    _ponerProducto(cambiado);
    notifyListeners();
  }

  /// Saca [producto] de "Vender". Sus ventas no cambian.
  Future<void> desactivarProducto(Producto producto) async {
    await _repositorio.desactivarProducto(producto.id);
    _productos.removeWhere((p) => p.id == producto.id);
    notifyListeners();
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
