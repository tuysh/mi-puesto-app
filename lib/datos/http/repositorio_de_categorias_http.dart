import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Las categorías, contra el servidor.
///
/// Las de productos y las de gastos funcionan igual; solo cambia la ruta.
/// Por eso hay dos constructores y una sola clase.
class RepositorioDeCategoriasHttp implements RepositorioDeCategorias {
  /// Las categorías de productos.
  RepositorioDeCategoriasHttp.deProductos(this._api) : _ruta = '/categorias';

  /// Las categorías de gastos.
  RepositorioDeCategoriasHttp.deGastos(this._api)
    : _ruta = '/gastos/categorias';

  final ClienteDeApi _api;
  final String _ruta;

  @override
  Future<List<Categoria>> obtenerCategorias() async {
    final lista = await _api.pedir('GET', _ruta);
    return [for (final categoria in lista as List) categoriaDeJson(categoria)];
  }

  @override
  Future<Categoria> crearCategoria(String nombre) async {
    final categoria = await _api.pedir(
      'POST',
      _ruta,
      cuerpo: {'nombre': nombre},
    );
    return categoriaDeJson(categoria);
  }

  @override
  Future<Categoria> renombrarCategoria(
    String categoriaId,
    String nombre,
  ) async {
    final categoria = await _api.pedir(
      'PATCH',
      '$_ruta/$categoriaId',
      cuerpo: {'nombre': nombre},
    );
    return categoriaDeJson(categoria);
  }

  @override
  Future<void> eliminarCategoria(String categoriaId) async {
    await _api.pedir('DELETE', '$_ruta/$categoriaId');
  }
}

/// Arma una [Categoria]. También lo usa el catálogo.
Categoria categoriaDeJson(dynamic json) {
  return Categoria(
    id: idDeJson(json['id']),
    nombre: json['nombre'] as String,
    color: json['color'] as int? ?? 0,
    // El catálogo no dice cuántos productos tiene cada una.
    usos: json['usos'] as int? ?? 0,
  );
}
