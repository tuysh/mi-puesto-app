import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/banda_de_monto.dart';

/// La franja que dice si la caja cuadró: verde si lo contado es igual a lo
/// que debía haber, y ámbar si sobró o faltó dinero.
class BandaDeDiferencia extends StatelessWidget {
  const BandaDeDiferencia({
    super.key,
    required this.diferencia,
    this.detalleSiNoCuadra,
  });

  /// Contado − esperado: positivo sobró, negativo faltó, cero cuadró.
  final Dinero diferencia;

  /// Renglón pequeño bajo "Falta dinero" o "Sobró dinero"; por ejemplo, la
  /// nota que se escribió al cerrar.
  final String? detalleSiNoCuadra;

  @override
  Widget build(BuildContext context) {
    if (diferencia.esCero) {
      return BandaDeMonto(
        etiqueta: 'La caja cuadra',
        detalle: 'Hay justo lo que debe haber',
        monto: formatearDinero(Dinero.cero),
        tamanoDeMonto: 36,
      );
    }

    return BandaDeMonto(
      etiqueta: diferencia.esNegativo ? 'Falta dinero' : 'Sobró dinero',
      detalle: detalleSiNoCuadra,
      monto: formatearDinero(diferencia.absoluto),
      colores: Colores.alerta,
      tamanoDeMonto: 36,
    );
  }
}
