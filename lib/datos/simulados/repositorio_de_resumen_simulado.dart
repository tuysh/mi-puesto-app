import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/gasto.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/servidor_simulado.dart';
import 'package:mi_puesto/nucleo/fechas.dart';

/// El resumen, calculado con las ventas y los gastos que guarda el
/// servidor simulado. Las ventas canceladas no cuentan en nada.
///
/// Para no complicarlo, siempre calcula todas las secciones, aunque la
/// pantalla haya pedido solo algunas.
class RepositorioDeResumenSimulado implements RepositorioDeResumen {
  RepositorioDeResumenSimulado(this._servidor);

  final ServidorSimulado _servidor;

  @override
  Future<Resumen> obtenerResumen({
    required Periodo periodo,
    required DateTime fecha,
    required Set<SeccionDeResumen> secciones,
    OrdenDeProductos orden = OrdenDeProductos.cantidad,
    int cuantosProductos = 5,
  }) async {
    await _servidor.atenderALaDuena();

    final desde = switch (periodo) {
      Periodo.dia => soloElDia(fecha),
      Periodo.semana => lunesDe(fecha),
      Periodo.mes => primerDiaDelMesDe(fecha),
    };
    final hasta = switch (periodo) {
      Periodo.dia => soloElDia(fecha),
      Periodo.semana => domingoDe(fecha),
      Periodo.mes => ultimoDiaDelMesDe(fecha),
    };

    final ventas = [
      for (final venta in _servidor.ventas)
        if (!venta.estaCancelada && estaEntre(venta.creadaEn, desde, hasta))
          venta,
    ];
    final gastos = [
      for (final gasto in _servidor.gastos)
        if (estaEntre(gasto.fecha, desde, hasta)) gasto,
    ];

    return Resumen(
      periodo: periodo,
      desde: desde,
      hasta: hasta,
      totales: _totalesDe(ventas, gastos),
      porDia: [
        for (var dia = desde; !dia.isAfter(hasta); dia = sumarDias(dia, 1))
          _resumenDelDia(dia, ventas, gastos),
      ],
      masVendidos: _masVendidos(ventas, orden, cuantosProductos),
      gastosPorCategoria: _gastosPorCategoria(gastos),
    );
  }

  Totales _totalesDe(List<Venta> ventas, List<Gasto> gastos) {
    final vendido = sumarDinero(ventas.map((venta) => venta.total));
    final gastado = sumarDinero(gastos.map((gasto) => gasto.monto));
    final enEfectivo = sumarDinero([
      for (final venta in ventas)
        if (venta.metodoDePago == MetodoDePago.efectivo) venta.total,
    ]);

    return Totales(
      vendido: vendido,
      numeroDeVentas: ventas.length,
      enEfectivo: enEfectivo,
      conTarjeta: vendido - enEfectivo,
      gastos: gastado,
      utilidad: vendido - gastado,
    );
  }

  DiaDeResumen _resumenDelDia(
    DateTime dia,
    List<Venta> ventas,
    List<Gasto> gastos,
  ) {
    final totales = _totalesDe(
      [
        for (final venta in ventas)
          if (esElMismoDia(venta.creadaEn, dia)) venta,
      ],
      [
        for (final gasto in gastos)
          if (esElMismoDia(gasto.fecha, dia)) gasto,
      ],
    );

    return DiaDeResumen(
      dia: dia,
      numeroDeVentas: totales.numeroDeVentas,
      vendido: totales.vendido,
      gastos: totales.gastos,
      utilidad: totales.utilidad,
    );
  }

  /// Junta los renglones de todas las ventas por producto y tamaño, y
  /// devuelve los primeros según [orden].
  List<ProductoVendido> _masVendidos(
    List<Venta> ventas,
    OrdenDeProductos orden,
    int cuantos,
  ) {
    final porProducto = <String, ProductoVendido>{};

    for (final venta in ventas) {
      for (final linea in venta.lineas) {
        final llave = '${linea.productoId}/${linea.presentacionId}';
        final anterior = porProducto[llave];
        final producto = _buscarProducto(linea.productoId);

        porProducto[llave] = ProductoVendido(
          nombreDelProducto: linea.nombreDelProducto,
          nombreDelTamano: linea.nombreDelTamano,
          categoriaId: producto?.categoriaId,
          representacion: producto?.representacion ?? Representacion.letras,
          emoji: producto?.emoji ?? '',
          letras: producto?.letras ?? '',
          imagenUrl: producto?.imagenUrl ?? '',
          piezas: (anterior?.piezas ?? 0) + linea.cantidad,
          vendido: (anterior?.vendido ?? Dinero.cero) + linea.subtotal,
        );
      }
    }

    final ordenados = porProducto.values.toList();
    if (orden == OrdenDeProductos.cantidad) {
      ordenados.sort((a, b) => b.piezas.compareTo(a.piezas));
    } else {
      ordenados.sort((a, b) => b.vendido.compareTo(a.vendido));
    }
    return ordenados.take(cuantos).toList();
  }

  List<GastoPorCategoria> _gastosPorCategoria(List<Gasto> gastos) {
    final totalPorCategoria = <String?, Dinero>{};
    for (final gasto in gastos) {
      totalPorCategoria[gasto.categoriaId] =
          (totalPorCategoria[gasto.categoriaId] ?? Dinero.cero) + gasto.monto;
    }

    return [
      for (final categoria in _servidor.categoriasDeGastos)
        if (totalPorCategoria.containsKey(categoria.id))
          GastoPorCategoria(
            nombre: categoria.nombre,
            color: categoria.color,
            total: totalPorCategoria[categoria.id]!,
          ),
      // Los gastos sin categoría salen juntos en un renglón al final.
      if (totalPorCategoria.containsKey(null))
        GastoPorCategoria(
          nombre: null,
          color: null,
          total: totalPorCategoria[null]!,
        ),
    ];
  }

  Producto? _buscarProducto(String productoId) {
    for (final producto in _servidor.productos) {
      if (producto.id == productoId) return producto;
    }
    return null;
  }
}
