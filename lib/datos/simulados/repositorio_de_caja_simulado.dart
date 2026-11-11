import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/gasto.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/servidor_simulado.dart';
import 'package:mi_puesto/nucleo/fechas.dart';

/// La caja, en memoria. Sus números se calculan con las ventas y los
/// gastos que guarda el servidor simulado.
class RepositorioDeCajaSimulado implements RepositorioDeCaja {
  RepositorioDeCajaSimulado(this._servidor);

  final ServidorSimulado _servidor;

  @override
  Future<Caja?> obtenerCajaAbierta() async {
    final perfil = await _servidor.atenderAAlguien();

    final caja = _servidor.cajaAbierta;
    if (caja == null) return null;

    if (perfil.esDueno) return _conSusNumeros(caja);

    // Quien solo vende sabe que está abierta, pero no recibe los montos.
    return Caja(id: caja.id, fecha: caja.fecha, abierta: true);
  }

  @override
  Future<Caja> abrirCaja(Dinero fondoInicial) async {
    await _servidor.atenderALaDuena();

    if (_servidor.cajaAbierta != null) {
      throw const ErrorDelServidor(
        'Ya hay una caja abierta. Primero ciérrala.',
        codigoHttp: 409,
        codigo: 'caja_abierta',
      );
    }

    final caja = Caja(
      id: _servidor.idNuevo(),
      fecha: hoy(),
      abierta: true,
      fondoInicial: fondoInicial,
    );
    _servidor.cajaAbierta = caja;
    return _conSusNumeros(caja);
  }

  @override
  Future<Caja> cerrarCaja({
    required Dinero contado,
    required String nota,
  }) async {
    final duena = await _servidor.atenderALaDuena();
    final abierta = _conSusNumeros(_servidor.exigirCajaAbierta());

    final cerrada = Caja(
      id: abierta.id,
      fecha: abierta.fecha,
      abierta: false,
      fondoInicial: abierta.fondoInicial,
      ventasEnEfectivo: abierta.ventasEnEfectivo,
      ventasConTarjeta: abierta.ventasConTarjeta,
      numeroDeVentas: abierta.numeroDeVentas,
      gastosTotales: abierta.gastosTotales,
      gastosDeCaja: abierta.gastosDeCaja,
      efectivoEsperado: abierta.efectivoEsperado,
      cerradaEn: DateTime.now(),
      cerradaPorId: duena.id,
      efectivoContado: contado,
      diferencia: contado - abierta.efectivoEsperado,
      nota: nota,
    );

    _servidor.cajasCerradas.add(cerrada);
    _servidor.cajaAbierta = null;
    _congelarGastosDeCaja();
    return cerrada;
  }

  @override
  Future<PaginaDeCierres> obtenerCierres({String? antes}) async {
    await _servidor.atenderALaDuena();

    return PaginaDeCierres(
      cierres: [
        // `reversed`: del más nuevo al más viejo.
        for (final caja in _servidor.cajasCerradas.reversed)
          CierreResumido(
            id: caja.id,
            fecha: caja.fecha,
            vendido: caja.vendido,
            diferencia: caja.diferencia ?? Dinero.cero,
          ),
      ],
      // En memoria todo cabe en una sola página.
      siguiente: null,
    );
  }

  @override
  Future<Caja> obtenerCierre(String cajaId) async {
    await _servidor.atenderALaDuena();
    return _servidor.cajasCerradas.firstWhere((caja) => caja.id == cajaId);
  }

  /// La caja abierta con sus montos de este momento.
  Caja _conSusNumeros(Caja caja) {
    final ventas = _servidor.ventasQueCuentanDe(caja.id);
    final enEfectivo = _sumar(ventas, MetodoDePago.efectivo);
    final conTarjeta = _sumar(ventas, MetodoDePago.tarjeta);

    final gastosDelDia = _servidor.gastos.where(
      (gasto) => esElMismoDia(gasto.fecha, caja.fecha),
    );
    final gastosDeCaja = _servidor.gastos.where(_sePagoDeLaCajaAbierta);
    final totalDeCaja = sumarDinero(gastosDeCaja.map((gasto) => gasto.monto));

    return Caja(
      id: caja.id,
      fecha: caja.fecha,
      abierta: true,
      fondoInicial: caja.fondoInicial,
      ventasEnEfectivo: enEfectivo,
      ventasConTarjeta: conTarjeta,
      numeroDeVentas: ventas.length,
      gastosTotales: sumarDinero(gastosDelDia.map((gasto) => gasto.monto)),
      gastosDeCaja: totalDeCaja,
      // Tarjeta y ventas canceladas no entran a la caja.
      efectivoEsperado: caja.fondoInicial + enEfectivo - totalDeCaja,
    );
  }

  Dinero _sumar(List<Venta> ventas, MetodoDePago metodo) {
    return sumarDinero([
      for (final venta in ventas)
        if (venta.metodoDePago == metodo) venta.total,
    ]);
  }

  /// Un gasto "de la caja" que todavía se puede editar es de la caja
  /// abierta: al cerrarla, sus gastos dejan de ser editables.
  bool _sePagoDeLaCajaAbierta(Gasto gasto) => gasto.deCaja && gasto.editable;

  void _congelarGastosDeCaja() {
    _servidor.gastos = [
      for (final gasto in _servidor.gastos)
        if (!_sePagoDeLaCajaAbierta(gasto))
          gasto
        else
          Gasto(
            id: gasto.id,
            concepto: gasto.concepto,
            monto: gasto.monto,
            fecha: gasto.fecha,
            categoriaId: gasto.categoriaId,
            deCaja: true,
            editable: false,
          ),
    ];
  }
}
