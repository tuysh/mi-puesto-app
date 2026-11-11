import 'package:mi_puesto/datos/modelos/dinero.dart';

/// Dinero que salió del negocio: ingredientes, gas, la cuota de la plaza…
class Gasto {
  const Gasto({
    required this.id,
    required this.concepto,
    required this.monto,
    required this.fecha,
    required this.categoriaId,
    required this.deCaja,
    this.editable = true,
  });

  /// Vacío mientras el gasto no se haya guardado (ver [esNuevo]).
  final String id;

  /// En qué se gastó: "Tanque de gas".
  final String concepto;

  final Dinero monto;
  final DateTime fecha;

  /// `null` si el gasto no tiene categoría.
  final String? categoriaId;

  /// `true` si se pagó con efectivo de la caja: se descuenta de lo que
  /// debe haber al cerrar. `false` si se pagó aparte.
  final bool deCaja;

  /// `false` si se pagó con una caja que ya se cerró: ya no se puede
  /// cambiar ni borrar.
  final bool editable;

  bool get esNuevo => id.isEmpty;
}

/// Los gastos de un rango de fechas.
class GastosDelPeriodo {
  const GastosDelPeriodo({
    required this.desde,
    required this.hasta,
    required this.total,
    required this.gastos,
  });

  final DateTime desde;

  /// El último día incluido.
  final DateTime hasta;

  final Dinero total;
  final List<Gasto> gastos;
}
