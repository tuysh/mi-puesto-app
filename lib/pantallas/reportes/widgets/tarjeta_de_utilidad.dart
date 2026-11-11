import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/nucleo/widgets/cifra_con_doble_raya.dart';
import 'package:mi_puesto/nucleo/widgets/linea_punteada.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_elevada.dart';

/// La cuenta del periodo en "Reportes", como en una libreta: lo vendido,
/// menos los gastos y, con doble raya, la utilidad. Las ventas canceladas
/// no cuentan.
class TarjetaDeUtilidad extends StatelessWidget {
  const TarjetaDeUtilidad({super.key, required this.totales});

  final Totales totales;

  @override
  Widget build(BuildContext context) {
    final ventas = totales.numeroDeVentas;

    return TarjetaElevada(
      relleno: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          _construirRenglon(
            'Vendido · $ventas ${ventas == 1 ? 'venta' : 'ventas'}',
            formatearDinero(totales.vendido),
          ),
          _construirRenglon('− Gastos', formatearDinero(totales.gastos)),
          const LineaPunteada(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Utilidad', style: Tipografia.texto(18, peso: 800)),
              CifraConDobleRaya(formatearDinero(totales.utilidad), tamano: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirRenglon(String concepto, String monto) {
    return Row(
      spacing: 12,
      children: [
        Expanded(child: Text(concepto, style: Tipografia.texto(16))),
        Cifra(monto, tamano: 20, peso: 750),
      ],
    );
  }
}
