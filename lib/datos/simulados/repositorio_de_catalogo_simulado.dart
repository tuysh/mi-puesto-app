import 'package:mi_puesto/datos/modelos/catalogo.dart';
import 'package:mi_puesto/datos/modelos/foto_nueva.dart';
import 'package:mi_puesto/datos/modelos/presentacion.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/servidor_simulado.dart';

/// Los productos, en memoria.
class RepositorioDeCatalogoSimulado implements RepositorioDeCatalogo {
  RepositorioDeCatalogoSimulado(this._servidor);

  final ServidorSimulado _servidor;

  @override
  Future<Catalogo> obtenerCatalogo() async {
    await _servidor.atenderAAlguien();

    return Catalogo(
      categorias: List.unmodifiable(_servidor.categorias),
      productos: List.unmodifiable(_servidor.productos),
    );
  }

  @override
  Future<Producto> guardarProducto(Producto producto) async {
    await _servidor.atenderALaDuena();

    final guardado = Producto(
      id: producto.esNuevo ? _servidor.idNuevo() : producto.id,
      nombre: producto.nombre,
      categoriaId: producto.categoriaId,
      precio: producto.tieneTamanos ? null : producto.precio,
      presentaciones: [
        for (final presentacion in producto.presentaciones)
          Presentacion(
            // Los tamaños nuevos reciben su `id` aquí, como en el servidor.
            id: presentacion.esNueva ? _servidor.idNuevo() : presentacion.id,
            nombre: presentacion.nombre,
            precio: presentacion.precio,
          ),
      ],
      representacion: producto.representacion,
      emoji: producto.emoji,
      letras: producto.letras.isEmpty
          ? _dosPrimerasLetras(producto.nombre)
          : producto.letras,
      imagenUrl: producto.imagenUrl,
      disponible: producto.disponible,
    );

    _poner(guardado);
    return guardado;
  }

  @override
  Future<Producto> cambiarDisponibilidad(
    String productoId,
    bool disponible,
  ) async {
    await _servidor.atenderALaDuena();
    return _poner(_buscar(productoId).copiarCon(disponible: disponible));
  }

  @override
  Future<void> desactivarProducto(String productoId) async {
    await _servidor.atenderALaDuena();
    _servidor.productos.removeWhere((producto) => producto.id == productoId);
  }

  @override
  Future<Producto> subirFotoDeProducto(
    String productoId,
    FotoNueva foto,
  ) async {
    await _servidor.atenderALaDuena();

    // Aquí no hay servidor que guarde la foto: la imagen completa viaja
    // dentro de la propia dirección (una dirección `data:`).
    final direccion = Uri.dataFromBytes(foto.bytes, mimeType: 'image/jpeg');
    return _poner(
      _buscar(productoId).copiarCon(
        representacion: Representacion.imagen,
        imagenUrl: direccion.toString(),
      ),
    );
  }

  @override
  Future<Producto> quitarFotoDeProducto(String productoId) async {
    await _servidor.atenderALaDuena();

    final producto = _buscar(productoId);
    return _poner(
      producto.copiarCon(
        // Vuelve al emoji si tiene; si no, a las letras.
        representacion: producto.emoji.isEmpty
            ? Representacion.letras
            : Representacion.emoji,
        imagenUrl: '',
      ),
    );
  }

  Producto _buscar(String productoId) {
    return _servidor.productos.firstWhere((p) => p.id == productoId);
  }

  /// Agrega [producto] a la lista o reemplaza al que tenía su mismo `id`.
  Producto _poner(Producto producto) {
    final posicion = _servidor.productos.indexWhere((p) => p.id == producto.id);
    final yaExistia = posicion != -1;
    if (yaExistia) {
      _servidor.productos[posicion] = producto;
    } else {
      _servidor.productos.add(producto);
    }
    return producto;
  }

  /// Lo que el servidor pone de letras cuando no se mandan: "Pozole" → "Po".
  String _dosPrimerasLetras(String nombre) {
    final limpio = nombre.trim();
    return limpio.length <= 2 ? limpio : limpio.substring(0, 2);
  }
}
