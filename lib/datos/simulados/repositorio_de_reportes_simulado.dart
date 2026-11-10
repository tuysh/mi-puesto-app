import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/modelos/reporte.dart';
import 'package:mi_puesto/datos/modelos/resumen_del_dia.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/datos_de_ejemplo.dart';
import 'package:mi_puesto/datos/simulados/espera_simulada.dart';

/// Devuelve siempre los mismos números de ejemplo: las ventas que se
/// registran en la aplicación NO cambian estos reportes. Eso lo hará el
/// backend real.
class RepositorioDeReportesSimulado implements RepositorioDeReportes {
  @override
  Future<ResumenDelDia> obtenerResumenDeHoy() async {
    await esperaSimulada();

    return ResumenDelDia(
      fecha: DateTime.now(),
      vendido: const Dinero.pesos(1240),
      ganancia: const Dinero.pesos(610),
      numeroDeVentas: 23,
      masVendidos: [
        _vendido(productosDeEjemplo[0], piezas: 9),
        _vendido(productosDeEjemplo[5], piezas: 7),
        _vendido(productosDeEjemplo[9], piezas: 5),
      ],
      ventasPorVendedor: const [
        VentaPorVendedor(nombre: 'Mari', total: Dinero.pesos(820)),
        VentaPorVendedor(nombre: 'Lupe', total: Dinero.pesos(420)),
      ],
    );
  }

  @override
  Future<Reporte> obtenerReporte(Periodo periodo) async {
    await esperaSimulada();

    return switch (periodo) {
      Periodo.dia => _reporteDelDia,
      Periodo.semana => _reporteDeLaSemana,
      Periodo.mes => _reporteDelMes,
    };
  }
}

final _reporteDelDia = Reporte(
  periodo: Periodo.dia,
  vendido: Dinero.pesos(1240),
  ganancia: Dinero.pesos(610),
  tramos: [
    _tramo('10h', 90, 40),
    _tramo('11h', 160, 80),
    _tramo('12h', 210, 105),
    _tramo('13h', 280, 140),
    _tramo('14h', 240, 115),
    _tramo('15h', 150, 75),
    _tramo('16h', 110, 55, esActual: true),
  ],
  ventasPorCategoria: const [
    VentaPorCategoria(categoria: postres, total: Dinero.pesos(540)),
    VentaPorCategoria(categoria: antojos, total: Dinero.pesos(390)),
    VentaPorCategoria(categoria: bebidas, total: Dinero.pesos(210)),
    VentaPorCategoria(categoria: dulces, total: Dinero.pesos(100)),
  ],
);

final _reporteDeLaSemana = Reporte(
  periodo: Periodo.semana,
  vendido: Dinero.pesos(6820),
  ganancia: Dinero.pesos(3310),
  tramos: [
    _tramo('L', 820, 400),
    _tramo('M', 760, 360),
    _tramo('M', 910, 440),
    _tramo('J', 1240, 610, esActual: true),
    _tramo('V', 1180, 570),
    _tramo('S', 1310, 640),
    _tramo('D', 600, 290),
  ],
  ventasPorCategoria: const [
    VentaPorCategoria(categoria: postres, total: Dinero.pesos(2980)),
    VentaPorCategoria(categoria: antojos, total: Dinero.pesos(2140)),
    VentaPorCategoria(categoria: bebidas, total: Dinero.pesos(1160)),
    VentaPorCategoria(categoria: dulces, total: Dinero.pesos(540)),
  ],
);

final _reporteDelMes = Reporte(
  periodo: Periodo.mes,
  vendido: Dinero.pesos(27400),
  ganancia: Dinero.pesos(13250),
  tramos: [
    _tramo('S1', 6400, 3100),
    _tramo('S2', 7100, 3450),
    _tramo('S3', 7080, 3390),
    _tramo('S4', 6820, 3310, esActual: true),
  ],
  ventasPorCategoria: const [
    VentaPorCategoria(categoria: postres, total: Dinero.pesos(11900)),
    VentaPorCategoria(categoria: antojos, total: Dinero.pesos(8600)),
    VentaPorCategoria(categoria: bebidas, total: Dinero.pesos(4700)),
    VentaPorCategoria(categoria: dulces, total: Dinero.pesos(2200)),
  ],
);

/// Atajo para escribir los tramos de arriba con montos en pesos.
TramoDeReporte _tramo(
  String etiqueta,
  int vendidoEnPesos,
  int gananciaEnPesos, {
  bool esActual = false,
}) {
  return TramoDeReporte(
    etiqueta: etiqueta,
    vendido: Dinero.pesos(vendidoEnPesos),
    ganancia: Dinero.pesos(gananciaEnPesos),
    esActual: esActual,
  );
}

ProductoVendido _vendido(Producto producto, {required int piezas}) {
  return ProductoVendido(
    productoId: producto.id,
    nombre: producto.nombre,
    emoji: producto.emoji,
    piezas: piezas,
  );
}
