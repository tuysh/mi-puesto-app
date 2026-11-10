import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/foto_nueva.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/datos_de_ejemplo.dart';
import 'package:mi_puesto/datos/simulados/espera_simulada.dart';

class RepositorioDeCatalogoSimulado implements RepositorioDeCatalogo {
  final List<Categoria> _categorias = [...categoriasDeEjemplo];
  final List<Producto> _productos = [...productosDeEjemplo];

  /// Número que se usará para el `id` de la siguiente categoría nueva.
  int _siguienteNumeroDeCategoria = categoriasDeEjemplo.length + 1;

  /// Número que se usará para el `id` del siguiente producto nuevo.
  int _siguienteNumero = productosDeEjemplo.length + 1;

  @override
  Future<List<Categoria>> obtenerCategorias() async {
    await esperaSimulada();
    return List.unmodifiable(_categorias);
  }

  @override
  Future<Categoria> guardarCategoria(Categoria categoria) async {
    await esperaSimulada();

    if (categoria.esNueva) {
      final creada = categoria.copiarCon(
        id: 'categoria-$_siguienteNumeroDeCategoria',
      );
      _siguienteNumeroDeCategoria++;
      _categorias.add(creada);
      return creada;
    }

    final posicion = _categorias.indexWhere((c) => c.id == categoria.id);
    _categorias[posicion] = categoria;
    return categoria;
  }

  @override
  Future<void> eliminarCategoria(String categoriaId) async {
    await esperaSimulada();
    _categorias.removeWhere((categoria) => categoria.id == categoriaId);
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

  @override
  Future<Producto> subirFotoDeProducto(String productoId, FotoNueva foto) {
    // Aquí no hay servidor que guarde la foto: la imagen completa viaja
    // dentro de la propia dirección (una dirección `data:`).
    final direccion = Uri.dataFromBytes(foto.bytes, mimeType: 'image/jpeg');
    return _cambiarFoto(productoId, direccion.toString());
  }

  @override
  Future<Producto> quitarFotoDeProducto(String productoId) {
    return _cambiarFoto(productoId, '');
  }

  Future<Producto> _cambiarFoto(String productoId, String fotoUrl) async {
    await esperaSimulada();

    final posicion = _productos.indexWhere((p) => p.id == productoId);
    return _productos[posicion] = _productos[posicion].copiarCon(
      fotoUrl: fotoUrl,
    );
  }
}
