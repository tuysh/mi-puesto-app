import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/gasto.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/servidor_simulado.dart';

/// Las categorías, en memoria. Igual que en el servidor de verdad, las de
/// productos y las de gastos funcionan igual: hay dos constructores y una
/// sola clase.
class RepositorioDeCategoriasSimulado implements RepositorioDeCategorias {
  /// Las categorías de productos.
  RepositorioDeCategoriasSimulado.deProductos(this._servidor)
    : _sonDeGastos = false;

  /// Las categorías de gastos.
  RepositorioDeCategoriasSimulado.deGastos(this._servidor)
    : _sonDeGastos = true;

  final ServidorSimulado _servidor;
  final bool _sonDeGastos;

  List<Categoria> get _categorias {
    return _sonDeGastos ? _servidor.categoriasDeGastos : _servidor.categorias;
  }

  @override
  Future<List<Categoria>> obtenerCategorias() async {
    await _servidor.atenderALaDuena();

    return [
      for (final categoria in _categorias)
        Categoria(
          id: categoria.id,
          nombre: categoria.nombre,
          color: categoria.color,
          usos: _contarUsos(categoria.id),
        ),
    ];
  }

  @override
  Future<Categoria> crearCategoria(String nombre) async {
    await _servidor.atenderALaDuena();
    _revisarQueElNombreEsteLibre(nombre, categoriaId: null);

    final categoria = Categoria(
      id: _servidor.idNuevo(),
      nombre: nombre,
      color: _servidor.siguienteColor(_categorias),
    );
    _categorias.add(categoria);
    return categoria;
  }

  @override
  Future<Categoria> renombrarCategoria(
    String categoriaId,
    String nombre,
  ) async {
    await _servidor.atenderALaDuena();
    _revisarQueElNombreEsteLibre(nombre, categoriaId: categoriaId);

    final posicion = _categorias.indexWhere((c) => c.id == categoriaId);
    return _categorias[posicion] = Categoria(
      id: categoriaId,
      nombre: nombre,
      color: _categorias[posicion].color,
    );
  }

  @override
  Future<void> eliminarCategoria(String categoriaId) async {
    await _servidor.atenderALaDuena();

    _categorias.removeWhere((categoria) => categoria.id == categoriaId);
    if (_sonDeGastos) {
      _dejarGastosSinCategoria(categoriaId);
    } else {
      _dejarProductosSinCategoria(categoriaId);
    }
  }

  int _contarUsos(String categoriaId) {
    if (_sonDeGastos) {
      return _servidor.gastos.where((g) => g.categoriaId == categoriaId).length;
    }
    return _servidor.productos
        .where((p) => p.categoriaId == categoriaId)
        .length;
  }

  /// No puede haber dos con el mismo nombre (sin distinguir mayúsculas).
  /// [categoriaId] es la que se está renombrando (su nombre no cuenta).
  void _revisarQueElNombreEsteLibre(
    String nombre, {
    required String? categoriaId,
  }) {
    final yaExiste = _categorias.any(
      (categoria) =>
          categoria.id != categoriaId &&
          categoria.nombre.toLowerCase() == nombre.toLowerCase(),
    );
    if (yaExiste) {
      throw const ErrorDelServidor(
        'Ya hay una categoría con ese nombre.',
        codigoHttp: 400,
      );
    }
  }

  void _dejarProductosSinCategoria(String categoriaId) {
    _servidor.productos = [
      for (final producto in _servidor.productos)
        if (producto.categoriaId != categoriaId)
          producto
        else
          Producto(
            id: producto.id,
            nombre: producto.nombre,
            categoriaId: null,
            precio: producto.precio,
            presentaciones: producto.presentaciones,
            representacion: producto.representacion,
            emoji: producto.emoji,
            letras: producto.letras,
            imagenUrl: producto.imagenUrl,
            disponible: producto.disponible,
          ),
    ];
  }

  void _dejarGastosSinCategoria(String categoriaId) {
    _servidor.gastos = [
      for (final gasto in _servidor.gastos)
        if (gasto.categoriaId != categoriaId)
          gasto
        else
          Gasto(
            id: gasto.id,
            concepto: gasto.concepto,
            monto: gasto.monto,
            fecha: gasto.fecha,
            categoriaId: null,
            deCaja: gasto.deCaja,
            editable: gasto.editable,
          ),
    ];
  }
}
