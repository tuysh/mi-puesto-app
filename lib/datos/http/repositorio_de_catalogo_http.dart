import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/http/repositorio_de_categorias_http.dart';
import 'package:mi_puesto/datos/modelos/catalogo.dart';
import 'package:mi_puesto/datos/modelos/foto_nueva.dart';
import 'package:mi_puesto/datos/modelos/presentacion.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Los productos y lo que se pinta al vender, contra el servidor.
class RepositorioDeCatalogoHttp implements RepositorioDeCatalogo {
  RepositorioDeCatalogoHttp(this._api);

  final ClienteDeApi _api;

  @override
  Future<Catalogo> obtenerCatalogo() async {
    final respuesta = await _api.pedir('GET', '/catalogo');

    return Catalogo(
      categorias: [
        for (final categoria in respuesta['categorias'] as List)
          categoriaDeJson(categoria),
      ],
      productos: [
        for (final producto in respuesta['productos'] as List)
          _productoDeJson(producto),
      ],
    );
  }

  @override
  Future<Producto> guardarProducto(Producto producto) async {
    final cuerpo = _productoAJson(producto);

    final guardado = producto.esNuevo
        ? await _api.pedir('POST', '/productos', cuerpo: cuerpo)
        : await _api.pedir(
            'PATCH',
            '/productos/${producto.id}',
            cuerpo: cuerpo,
          );
    return _productoDeJson(guardado);
  }

  @override
  Future<Producto> cambiarDisponibilidad(
    String productoId,
    bool disponible,
  ) async {
    final producto = await _api.pedir(
      'PATCH',
      '/productos/$productoId',
      cuerpo: {'disponible': disponible},
    );
    return _productoDeJson(producto);
  }

  @override
  Future<void> desactivarProducto(String productoId) async {
    await _api.pedir(
      'PATCH',
      '/productos/$productoId',
      cuerpo: {'activo': false},
    );
  }

  @override
  Future<Producto> subirFotoDeProducto(
    String productoId,
    FotoNueva foto,
  ) async {
    final producto = await _api.subirArchivo(
      '/productos/$productoId/foto',
      campo: 'foto',
      bytes: foto.bytes,
      nombreDeArchivo: foto.nombreDeArchivo,
    );
    return _productoDeJson(producto);
  }

  @override
  Future<Producto> quitarFotoDeProducto(String productoId) async {
    final producto = await _api.pedir('DELETE', '/productos/$productoId/foto');
    return _productoDeJson(producto);
  }

  /// Lo que se manda al crear o cambiar un producto.
  Map<String, Object?> _productoAJson(Producto producto) {
    final categoriaId = producto.categoriaId;

    return {
      'nombre': producto.nombre,
      'categoria_id': categoriaId == null ? null : idAJson(categoriaId),
      'letras': producto.letras,
      'emoji': producto.emoji,
      // "imagen" no se manda: el servidor la pone solo al subir la foto.
      if (producto.representacion != Representacion.imagen)
        'representacion': producto.representacion.name,
      // Un precio o tamaños, nunca los dos.
      if (producto.tieneTamanos)
        'presentaciones': [
          for (final presentacion in producto.presentaciones)
            {
              // Con `id` el servidor actualiza ese tamaño; sin él, lo crea.
              if (!presentacion.esNueva) 'id': idAJson(presentacion.id),
              'nombre': presentacion.nombre,
              'precio': dineroAJson(presentacion.precio),
            },
        ]
      else
        'precio': dineroAJson(producto.precio!),
    };
  }

  Producto _productoDeJson(dynamic json) {
    return Producto(
      id: idDeJson(json['id']),
      nombre: json['nombre'] as String,
      categoriaId: idONadaDeJson(json['categoria_id']),
      precio: dineroONadaDeJson(json['precio']),
      presentaciones: [
        // Viene sin esta llave cuando se piden solo algunos campos.
        for (final presentacion in json['presentaciones'] as List? ?? [])
          Presentacion(
            id: idDeJson(presentacion['id']),
            nombre: presentacion['nombre'] as String,
            precio: dineroDeJson(presentacion['precio']),
          ),
      ],
      representacion: representacionDeJson(json['representacion']),
      emoji: json['emoji'] as String? ?? '',
      letras: json['letras'] as String? ?? '',
      imagenUrl: _api.direccionDeFoto(json['imagen_url'] as String? ?? ''),
      disponible: json['disponible'] as bool? ?? true,
    );
  }
}

/// Lee con qué se pinta un producto: `"imagen"`, `"emoji"` o `"letras"`.
/// También lo usa el resumen, para "Lo más vendido".
Representacion representacionDeJson(Object? valor) {
  return switch (valor) {
    'imagen' => Representacion.imagen,
    'emoji' => Representacion.emoji,
    _ => Representacion.letras,
  };
}
