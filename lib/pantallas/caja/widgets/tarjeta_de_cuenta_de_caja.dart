import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra_con_doble_raya.dart';
import 'package:mi_puesto/nucleo/widgets/linea_punteada.dart';
import 'package:mi_puesto/nucleo/widgets/renglon_de_monto.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_elevada.dart';

/// La cuenta de la libreta: con lo que se abrió, más lo vendido, igual a
/// lo que debe haber en la caja.
class TarjetaDeCuentaDeCaja extends StatelessWidget {
  const TarjetaDeCuentaDeCaja({super.key, required this.cuenta});

  final CuentaDeCaja cuenta;

  @override
  Widget build(BuildContext context) {
    return TarjetaElevada(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          RenglonDeMonto(
            concepto: 'Con lo que abriste',
            monto: formatearDinero(cuenta.fondoInicial),
            tamano: 17,
          ),
          RenglonDeMonto(
            concepto: '+ Vendido en efectivo',
            monto: formatearDinero(cuenta.vendidoEnEfectivo),
            tamano: 17,
          ),
          const LineaPunteada(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Debe haber', style: Tipografia.texto(17, peso: 800)),
              CifraConDobleRaya(formatearDinero(cuenta.debeHaber), tamano: 40),
            ],
          ),
        ],
      ),
    );
  }
}
