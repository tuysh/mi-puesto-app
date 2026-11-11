import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra_con_doble_raya.dart';
import 'package:mi_puesto/nucleo/widgets/linea_punteada.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_elevada.dart';
import 'package:mi_puesto/pantallas/caja/widgets/renglon_de_cuenta.dart';

/// La cuenta de la libreta al cerrar caja: con lo que se abrió, más lo
/// vendido en efectivo, menos los gastos pagados de la caja; y en grande,
/// lo que debe haber.
class TarjetaDeCuentaDeCaja extends StatelessWidget {
  const TarjetaDeCuentaDeCaja({super.key, required this.caja});

  final Caja caja;

  @override
  Widget build(BuildContext context) {
    return TarjetaElevada(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          RenglonDeCuenta(
            concepto: 'Con lo que abriste',
            monto: formatearDinero(caja.fondoInicial),
            tamano: 17,
          ),
          RenglonDeCuenta(
            concepto: '+ Vendido en efectivo',
            monto: formatearDinero(caja.ventasEnEfectivo),
            tamano: 17,
          ),
          RenglonDeCuenta(
            concepto: '− Gastos pagados de la caja',
            monto: formatearDinero(caja.gastosDeCaja),
            tamano: 17,
          ),
          const LineaPunteada(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Debe haber', style: Tipografia.texto(17, peso: 800)),
              CifraConDobleRaya(
                formatearDinero(caja.efectivoEsperado),
                tamano: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
