import 'dart:math';

import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Categorías y productos, contra el servidor.
class RepositorioDeCatalogoHttp implements RepositorioDeCatalogo {
  RepositorioDeCatalogoHttp(this._api);

  final ClienteDeApi _api;

  /// El lugar más alto que ocupa una categoría en la lista. Una categoría
  /// nueva se manda con el siguiente, para que aparezca al final.
  int _ordenMasAlto = -1;

  @override
  Future<List<Categoria>> obtenerCategorias() async {
    final lista = await _api.pedir(
      'GET',
      '${await _api.rutaDelPuesto()}/categorias',
    );

    for (final categoria in lista as List) {
      _ordenMasAlto = max(_ordenMasAlto, categoria['orden'] as int);
    }
    return [for (final categoria in lista) categoriaDeJson(categoria)];
  }

  @override
  Future<Categoria> guardarCategoria(Categoria categoria) async {
    final ruta = '${await _api.rutaDelPuesto()}/categorias';
    final cuerpo = {
      'nombre': categoria.nombre,
      'emoji': categoria.emoji,
      'color_fondo': colorAJson(categoria.colores.fondo),
      'color_tinta': colorAJson(categoria.colores.tinta),
    };

    if (categoria.esNueva) {
      final creada = await _api.pedir(
        'POST',
        ruta,
        cuerpo: {...cuerpo, 'orden': _ordenMasAlto + 1},
      );
      _ordenMasAlto++;
      return categoriaDeJson(creada);
    }

    final cambiada = await _api.pedir(
      'PATCH',
      '$ruta/${categoria.id}',
      cuerpo: cuerpo,
    );
    return categoriaDeJson(cambiada);
  }

  @override
  Future<void> eliminarCategoria(String categoriaId) async {
    await _api.pedir(
      'DELETE',
      '${await _api.rutaDelPuesto()}/categorias/$categoriaId',
    );
  }

  @override
  Future<List<Producto>> obtenerProductos() async {
    final lista = await _api.pedir(
      'GET',
      '${await _api.rutaDelPuesto()}/productos',
    );
    return [for (final producto in lista as List) _productoDeJson(producto)];
  }

  @override
  Future<Producto> guardarProducto(Producto producto) async {
    final ruta = '${await _api.rutaDelPuesto()}/productos';
    final cuerpo = {
      'nombre': producto.nombre,
      // Si el nombre corto es el mismo nombre, no hace falta guardarlo:
      // el servidor lo limita a 24 letras y el nombre puede ser más largo.
      'nombre_corto': producto.nombreCorto == producto.nombre
          ? ''
          : producto.nombreCorto,
      'emoji': producto.emoji,
      'precio': dineroAJson(producto.precio),
      'costo': dineroAJson(producto.costo),
      'a_la_venta': producto.aLaVenta,
      'categoria_id': idAJson(producto.categoriaId),
    };

    final guardado = producto.esNuevo
        ? await _api.pedir('POST', ruta, cuerpo: cuerpo)
        : await _api.pedir('PATCH', '$ruta/${producto.id}', cuerpo: cuerpo);
    return _productoDeJson(guardado);
  }

  Producto _productoDeJson(dynamic json) {
    final nombre = json['nombre'] as String;
    final nombreCorto = json['nombre_corto'] as String? ?? '';

    return Producto(
      id: idDeJson(json['id']),
      nombre: nombre,
      nombreCorto: nombreCorto.isEmpty ? nombre : nombreCorto,
      emoji: json['emoji'] as String? ?? '',
      precio: dineroDeJson(json['precio']),
      costo: dineroDeJson(json['costo']),
      categoriaId: idDeJson(json['categoria_id']),
      aLaVenta: json['a_la_venta'] as bool? ?? true,
    );
  }
}

/// Arma una [Categoria] con lo que manda el servidor. También la usan los
/// reportes, que necesitan los colores de cada categoría.
Categoria categoriaDeJson(dynamic json) {
  return Categoria(
    id: idDeJson(json['id']),
    nombre: json['nombre'] as String,
    emoji: json['emoji'] as String? ?? '',
    colores: coloresDeJson(json['color_fondo'], json['color_tinta']),
  );
}
