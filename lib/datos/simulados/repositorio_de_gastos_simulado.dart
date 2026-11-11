import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/gasto.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/servidor_simulado.dart';
import 'package:mi_puesto/nucleo/fechas.dart';

/// Los gastos, en memoria.
class RepositorioDeGastosSimulado implements RepositorioDeGastos {
  RepositorioDeGastosSimulado(this._servidor);

  final ServidorSimulado _servidor;

  @override
  Future<GastosDelPeriodo> obtenerGastos({
    required DateTime desde,
    required DateTime hasta,
    String? categoriaId,
  }) async {
    await _servidor.atenderALaDuena();

    final gastos = [
      // `reversed`: del más nuevo al más viejo.
      for (final gasto in _servidor.gastos.reversed)
        if (estaEntre(gasto.fecha, desde, hasta) &&
            (categoriaId == null || gasto.categoriaId == categoriaId))
          gasto,
    ];

    return GastosDelPeriodo(
      desde: soloElDia(desde),
      hasta: soloElDia(hasta),
      total: sumarDinero(gastos.map((gasto) => gasto.monto)),
      gastos: gastos,
    );
  }

  @override
  Future<Gasto> guardarGasto(Gasto gasto) async {
    await _servidor.atenderALaDuena();

    if (!gasto.esNuevo) _revisarQueSePuedaCambiar(gasto.id);
    // Un gasto pagado de la caja se liga a la caja abierta.
    if (gasto.deCaja) _servidor.exigirCajaAbierta();

    final guardado = Gasto(
      id: gasto.esNuevo ? _servidor.idNuevo() : gasto.id,
      concepto: gasto.concepto,
      monto: gasto.monto,
      fecha: soloElDia(gasto.fecha),
      categoriaId: gasto.categoriaId,
      deCaja: gasto.deCaja,
    );

    final posicion = _servidor.gastos.indexWhere((g) => g.id == guardado.id);
    final yaExistia = posicion != -1;
    if (yaExistia) {
      _servidor.gastos[posicion] = guardado;
    } else {
      _servidor.gastos.add(guardado);
    }
    return guardado;
  }

  @override
  Future<void> eliminarGasto(String gastoId) async {
    await _servidor.atenderALaDuena();
    _revisarQueSePuedaCambiar(gastoId);

    _servidor.gastos.removeWhere((gasto) => gasto.id == gastoId);
  }

  /// Un gasto pagado con una caja que ya se cerró no se toca.
  void _revisarQueSePuedaCambiar(String gastoId) {
    final actual = _servidor.gastos.firstWhere((gasto) => gasto.id == gastoId);
    if (!actual.editable) {
      throw const ErrorDelServidor(
        'Ese gasto se pagó con una caja que ya se cerró.',
        codigoHttp: 409,
        codigo: 'caja_cerrada',
      );
    }
  }
}
