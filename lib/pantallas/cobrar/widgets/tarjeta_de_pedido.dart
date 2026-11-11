import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra_con_doble_raya.dart';
import 'package:mi_puesto/nucleo/widgets/linea_punteada.dart';
import 'package:mi_puesto/nucleo/widgets/renglon_de_monto.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_elevada.dart';

/// La cuenta de un pedido o de una venta: un renglón por producto
/// ("3 × Horchata grande   $75") y el total con doble raya.
class TarjetaDePedido extends StatelessWidget {
  const TarjetaDePedido({
    super.key,
    required this.renglones,
    required this.total,
    this.tamanoDeTotal = 48,
    this.alPie,
  });

  /// Cada renglón: qué se lleva y cuánto suma.
  final List<({String concepto, Dinero subtotal})> renglones;

  final Dinero total;
  final double tamanoDeTotal;

  /// Lo que va debajo del total, por ejemplo el enlace "Cambiar productos".
  final Widget? alPie;

  @override
  Widget build(BuildContext context) {
    return TarjetaElevada(
      relleno: EdgeInsets.fromLTRB(18, 16, 18, alPie == null ? 16 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          for (final renglon in renglones)
            RenglonDeMonto(
              concepto: renglon.concepto,
              monto: formatearDinero(renglon.subtotal),
            ),
          const SizedBox(height: 0),
          const LineaPunteada(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Tipografia.texto(18, peso: 800)),
              CifraConDobleRaya(formatearDinero(total), tamano: tamanoDeTotal),
            ],
          ),
          if (alPie != null)
            Align(alignment: Alignment.centerLeft, child: alPie),
        ],
      ),
    );
  }
}
