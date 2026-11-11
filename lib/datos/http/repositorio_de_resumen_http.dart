import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/http/repositorio_de_catalogo_http.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Los números de "Hoy", "Reportes" y el PDF, contra el servidor.
///
/// Todo sale de la ruta `/resumen`, pidiendo solo las secciones que cada
/// pantalla muestra.
class RepositorioDeResumenHttp implements RepositorioDeResumen {
  RepositorioDeResumenHttp(this._api);

  final ClienteDeApi _api;

  @override
  Future<Resumen> obtenerResumen({
    required Periodo periodo,
    required DateTime fecha,
    required Set<SeccionDeResumen> secciones,
    OrdenDeProductos orden = OrdenDeProductos.cantidad,
    int cuantosProductos = 5,
  }) async {
    final nombresDeSecciones = [
      for (final seccion in secciones) seccion.nombreEnElServidor,
    ];

    final json = await _api.pedir(
      'GET',
      '/resumen',
      consulta: {
        'periodo': periodo.name,
        'fecha': diaAJson(fecha),
        'secciones': nombresDeSecciones.join(','),
        'orden': orden.name,
        'top': '$cuantosProductos',
      },
    );

    // Las secciones que no se pidieron no vienen en la respuesta.
    final totales = json['totales'];
    return Resumen(
      periodo: periodo,
      desde: diaDeJson(json['desde']),
      hasta: diaDeJson(json['hasta']),
      totales: totales == null ? Totales.enCeros : _totalesDeJson(totales),
      porDia: [
        for (final dia in json['por_dia'] as List? ?? [])
          DiaDeResumen(
            dia: diaDeJson(dia['dia']),
            numeroDeVentas: dia['ventas'] as int,
            vendido: dineroDeJson(dia['vendido']),
            gastos: dineroDeJson(dia['gastos']),
            utilidad: dineroDeJson(dia['utilidad']),
          ),
      ],
      masVendidos: [
        for (final producto in json['top_productos'] as List? ?? [])
          ProductoVendido(
            nombreDelProducto: producto['nombre_producto'] as String,
            nombreDelTamano: producto['nombre_presentacion'] as String? ?? '',
            categoriaId: idONadaDeJson(producto['categoria_id']),
            representacion: representacionDeJson(producto['representacion']),
            emoji: producto['emoji'] as String? ?? '',
            letras: producto['letras'] as String? ?? '',
            imagenUrl: _api.direccionDeFoto(
              producto['imagen_url'] as String? ?? '',
            ),
            piezas: producto['piezas'] as int,
            vendido: dineroDeJson(producto['vendido']),
          ),
      ],
      gastosPorCategoria: [
        for (final renglon in json['gastos_por_categoria'] as List? ?? [])
          GastoPorCategoria(
            nombre: renglon['nombre'] as String?,
            color: renglon['color'] as int?,
            total: dineroDeJson(renglon['total']),
          ),
      ],
    );
  }

  Totales _totalesDeJson(dynamic json) {
    return Totales(
      vendido: dineroDeJson(json['vendido']),
      numeroDeVentas: json['ventas'] as int,
      enEfectivo: dineroDeJson(json['efectivo']),
      conTarjeta: dineroDeJson(json['tarjeta']),
      gastos: dineroDeJson(json['gastos']),
      utilidad: dineroDeJson(json['utilidad']),
    );
  }
}
