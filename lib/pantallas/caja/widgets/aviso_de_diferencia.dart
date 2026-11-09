import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/banda_de_monto.dart';

/// Dice si el dinero contado cuadra con lo que debe haber en la caja.
class AvisoDeDiferencia extends StatelessWidget {
  const AvisoDeDiferencia({super.key, required this.diferencia});

  /// Lo contado menos lo que debe haber.
  /// Negativo: falta dinero. Positivo: sobra. Cero: la caja cuadra.
  final Dinero diferencia;

  @override
  Widget build(BuildContext context) {
    if (diferencia.esCero) {
      return const BandaDeMonto(
        etiqueta: 'La caja cuadra',
        detalle: 'Está justo lo que debe haber',
        monto: '\$0',
        tamanoDeMonto: 36,
      );
    }

    return BandaDeMonto(
      etiqueta: diferencia.esNegativo ? 'Falta dinero' : 'Sobra dinero',
      detalle: 'Cuenta otra vez antes de cerrar',
      monto: formatearDinero(diferencia.absoluto),
      colores: Colores.alerta,
      tamanoDeMonto: 36,
    );
  }
}
