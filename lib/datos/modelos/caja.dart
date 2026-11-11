import 'package:mi_puesto/datos/modelos/dinero.dart';

/// La caja de un día: con cuánto se abrió, qué entró, qué salió y, una vez
/// cerrada, cuánto se contó.
///
/// Quien solo vende recibe nada más si está abierta y desde cuándo; para
/// esa persona todos los montos valen cero.
class Caja {
  const Caja({
    required this.id,
    required this.fecha,
    required this.abierta,
    this.fondoInicial = Dinero.cero,
    this.ventasEnEfectivo = Dinero.cero,
    this.ventasConTarjeta = Dinero.cero,
    this.numeroDeVentas = 0,
    this.gastosTotales = Dinero.cero,
    this.gastosDeCaja = Dinero.cero,
    this.efectivoEsperado = Dinero.cero,
    this.cerradaEn,
    this.cerradaPorId,
    this.efectivoContado,
    this.diferencia,
    this.nota = '',
  });

  final String id;

  /// El día en que se abrió.
  final DateTime fecha;

  final bool abierta;

  /// El dinero con el que se abrió, para dar cambio.
  final Dinero fondoInicial;

  final Dinero ventasEnEfectivo;
  final Dinero ventasConTarjeta;
  final int numeroDeVentas;

  /// Todos los gastos del día.
  final Dinero gastosTotales;

  /// Solo los gastos que se pagaron con efectivo de la caja.
  final Dinero gastosDeCaja;

  /// "Debe haber": fondo + ventas en efectivo − gastos pagados de la caja.
  final Dinero efectivoEsperado;

  final DateTime? cerradaEn;

  /// Quién la cerró.
  final String? cerradaPorId;

  /// Lo que se contó al cerrar.
  final Dinero? efectivoContado;

  /// Contado − esperado: positivo sobró, negativo faltó, cero cuadró.
  final Dinero? diferencia;

  final String nota;

  Dinero get vendido => ventasEnEfectivo + ventasConTarjeta;

  /// `true` si esta caja se abrió un día anterior a [hoy] y nadie la cerró.
  bool esDeUnDiaAnteriorA(DateTime hoy) {
    final soloElDia = DateTime(hoy.year, hoy.month, hoy.day);
    return fecha.isBefore(soloElDia);
  }
}

/// Un cierre anterior, como aparece en la lista "Cierres anteriores".
class CierreResumido {
  const CierreResumido({
    required this.id,
    required this.fecha,
    required this.vendido,
    required this.diferencia,
  });

  /// El id de la caja; con él se pide el cierre completo.
  final String id;

  final DateTime fecha;
  final Dinero vendido;
  final Dinero diferencia;
}

/// Una página de la lista de cierres.
class PaginaDeCierres {
  const PaginaDeCierres({required this.cierres, required this.siguiente});

  final List<CierreResumido> cierres;

  /// Con esto se pide la página que sigue; `null` si ya no hay más.
  final String? siguiente;
}
