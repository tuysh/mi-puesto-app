import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/datos_de_ejemplo.dart';
import 'package:mi_puesto/datos/simulados/espera_simulada.dart';

class RepositorioDeCatalogoSimulado implements RepositorioDeCatalogo {
  final List<Producto> _productos = [...productosDeEjemplo];

  /// Número que se usará para el `id` del siguiente producto nuevo.
  int _siguienteNumero = productosDeEjemplo.length + 1;

  @override
  Future<List<Categoria>> obtenerCategorias() async {
    await esperaSimulada();
    return categoriasDeEjemplo;
  }

  @override
  Future<List<Producto>> obtenerProductos() async {
    await esperaSimulada();
    return List.unmodifiable(_productos);
  }

  @override
  Future<Producto> guardarProducto(Producto producto) async {
    await esperaSimulada();

    if (producto.esNuevo) {
      final creado = producto.copiarCon(id: 'producto-$_siguienteNumero');
      _siguienteNumero++;
      _productos.add(creado);
      return creado;
    }

    final posicion = _productos.indexWhere((p) => p.id == producto.id);
    _productos[posicion] = producto;
    return producto;
  }
}
