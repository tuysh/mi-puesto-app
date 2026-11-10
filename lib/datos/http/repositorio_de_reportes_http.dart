import 'dart:math';

import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/http/repositorio_de_catalogo_http.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/reporte.dart';
import 'package:mi_puesto/datos/modelos/resumen_del_dia.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Los números de "Hoy" y "Reportes", contra el servidor.
///
/// Todo sale de la ruta `/resumen`, pidiendo solo las secciones que cada
/// pantalla muestra.
class RepositorioDeReportesHttp implements RepositorioDeReportes {
  RepositorioDeReportesHttp(this._api);

  final ClienteDeApi _api;

  static const _inicialesDeLosDias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Future<ResumenDelDia> obtenerResumenDeHoy() async {
    final resumen = await _api.pedir(
      'GET',
      '${await _api.rutaDelPuesto()}/resumen',
      consulta: {'secciones': 'totales,top_productos,por_vendedor'},
    );
    final totales = resumen['totales'];

    return ResumenDelDia(
      fecha: DateTime.parse(resumen['desde'] as String),
      vendido: dineroDeJson(totales['vendido']),
      ganancia: dineroDeJson(totales['ganancia']),
      numeroDeVentas: totales['ventas'] as int,
      masVendidos: [
        for (final producto in resumen['top_productos'] as List)
          ProductoVendido(
            productoId: idDeJson(producto['producto_id']),
            nombre: producto['nombre'] as String,
            emoji: producto['emoji'] as String? ?? '',
            piezas: producto['piezas'] as int,
          ),
      ],
      ventasPorVendedor: [
        for (final vendedor in resumen['por_vendedor'] as List)
          VentaPorVendedor(
            nombre: vendedor['nombre'] as String,
            total: dineroDeJson(vendedor['vendido']),
          ),
      ],
    );
  }

  @override
  Future<Reporte> obtenerReporte(Periodo periodo) async {
    final ruta = await _api.rutaDelPuesto();

    // El resumen y las categorías no dependen uno del otro: se piden a la
    // vez. Las categorías hacen falta por sus colores, que el resumen no
    // trae.
    final pedidoDeResumen = _api.pedir(
      'GET',
      '$ruta/resumen',
      consulta: {
        'periodo': periodo.name,
        // La gráfica del día va por hora y se arma con las ventas (abajo).
        'secciones': periodo == Periodo.dia
            ? 'totales,por_categoria'
            : 'totales,por_dia,por_categoria',
      },
    );
    final pedidoDeCategorias = _api.pedir('GET', '$ruta/categorias');
    final resumen = await pedidoDeResumen;
    final categorias = {
      for (final categoria in await pedidoDeCategorias as List)
        idDeJson(categoria['id']): categoriaDeJson(categoria),
    };

    final hoy = diaAJson(DateTime.now());
    final tramos = switch (periodo) {
      Periodo.dia => await _tramosPorHora(ruta, resumen['desde'] as String),
      Periodo.semana => _tramosPorDia(resumen['por_dia'] as List, hoy),
      Periodo.mes => _tramosPorSemana(resumen['por_dia'] as List, hoy),
    };

    final renglonesDeCategoria = resumen['por_categoria'] as List;
    return Reporte(
      periodo: periodo,
      vendido: dineroDeJson(resumen['totales']['vendido']),
      ganancia: dineroDeJson(resumen['totales']['ganancia']),
      tramos: tramos,
      ventasPorCategoria: [
        for (final (posicion, renglon) in renglonesDeCategoria.indexed)
          VentaPorCategoria(
            categoria:
                categorias[idDeJson(renglon['categoria_id'])] ??
                // La categoría ya no existe: se arma con lo que el resumen
                // sí trae y un color cualquiera.
                Categoria(
                  id: idDeJson(renglon['categoria_id']),
                  nombre: renglon['nombre'] as String,
                  emoji: renglon['emoji'] as String? ?? '',
                  colores: Pasteles.paraIndice(posicion),
                ),
            total: dineroDeJson(renglon['vendido']),
          ),
      ],
    );
  }

  /// Semana: una barra por día, de lunes a domingo.
  List<TramoDeReporte> _tramosPorDia(List<dynamic> dias, String hoy) {
    return [
      for (final dia in dias)
        TramoDeReporte(
          etiqueta:
              _inicialesDeLosDias[DateTime.parse(dia['dia'] as String).weekday -
                  1],
          vendido: dineroDeJson(dia['vendido']),
          ganancia: dineroDeJson(dia['ganancia']),
          esActual: dia['dia'] == hoy,
        ),
    ];
  }

  /// Mes: los días se juntan de siete en siete (S1 es del 1 al 7, S2 del
  /// 8 al 14…) y cada grupo es una barra.
  List<TramoDeReporte> _tramosPorSemana(List<dynamic> dias, String hoy) {
    final tramos = <TramoDeReporte>[];

    for (var inicio = 0; inicio < dias.length; inicio += 7) {
      final semana = dias.sublist(inicio, min(inicio + 7, dias.length));
      tramos.add(
        TramoDeReporte(
          etiqueta: 'S${tramos.length + 1}',
          vendido: sumarDinero(semana.map((d) => dineroDeJson(d['vendido']))),
          ganancia: sumarDinero(semana.map((d) => dineroDeJson(d['ganancia']))),
          esActual: semana.any((dia) => dia['dia'] == hoy),
        ),
      );
    }
    return tramos;
  }

  /// Día: una barra por hora, desde la primera venta hasta la hora actual.
  ///
  /// El resumen no trae las horas, así que se suman las ventas del día
  /// según la hora (del dispositivo) en que se hicieron.
  Future<List<TramoDeReporte>> _tramosPorHora(String ruta, String dia) async {
    final vendidoPorHora = <int, Dinero>{};
    final gananciaPorHora = <int, Dinero>{};

    // El historial llega por páginas; `siguiente` dice si hay más.
    Object? antes;
    do {
      final pagina = await _api.pedir(
        'GET',
        '$ruta/ventas',
        consulta: {
          'desde': dia,
          'hasta': dia,
          'limite': '200',
          if (antes != null) 'antes': '$antes',
        },
      );

      for (final venta in pagina['ventas'] as List) {
        // Las ventas anuladas no cuentan.
        if (venta['anulada_en'] != null) continue;

        final hora = momentoDeJson(venta['creada_en']).hour;
        vendidoPorHora[hora] =
            (vendidoPorHora[hora] ?? Dinero.cero) +
            dineroDeJson(venta['total']);
        gananciaPorHora[hora] =
            (gananciaPorHora[hora] ?? Dinero.cero) +
            dineroDeJson(venta['ganancia']);
      }
      antes = pagina['siguiente'];
    } while (antes != null);

    if (vendidoPorHora.isEmpty) return [];

    final horaActual = DateTime.now().hour;
    final primeraHora = vendidoPorHora.keys.reduce(min);
    final ultimaHora = max(vendidoPorHora.keys.reduce(max), horaActual);
    return [
      for (var hora = primeraHora; hora <= ultimaHora; hora++)
        TramoDeReporte(
          etiqueta: '${hora}h',
          vendido: vendidoPorHora[hora] ?? Dinero.cero,
          ganancia: gananciaPorHora[hora] ?? Dinero.cero,
          esActual: hora == horaActual,
        ),
    ];
  }
}
