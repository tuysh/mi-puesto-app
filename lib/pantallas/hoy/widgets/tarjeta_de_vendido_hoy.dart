import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra_con_doble_raya.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_elevada.dart';

/// La tarjeta principal de "Hoy": lo vendido en grande, cuántas ventas
/// fueron y cuánto entró en efectivo y cuánto con tarjeta.
class TarjetaDeVendidoHoy extends StatelessWidget {
  const TarjetaDeVendidoHoy({super.key, required this.totales});

  final Totales totales;

  @override
  Widget build(BuildContext context) {
    final ventas = totales.numeroDeVentas;

    return TarjetaElevada(
      relleno: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            'Vendido hoy · $ventas ${ventas == 1 ? 'venta' : 'ventas'}',
            style: Tipografia.texto(15, peso: 800, color: Colores.tintaSuave),
          ),
          // FittedBox encoge la cifra si es tan grande que no cabe.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: CifraConDobleRaya(
              formatearDinero(totales.vendido),
              tamano: 52,
            ),
          ),
          Wrap(
            spacing: 18,
            children: [
              _construirMetodo('Efectivo', formatearDinero(totales.enEfectivo)),
              _construirMetodo('Tarjeta', formatearDinero(totales.conTarjeta)),
            ],
          ),
        ],
      ),
    );
  }

  /// "Efectivo $980": la palabra en texto normal y el monto como cifra.
  Widget _construirMetodo(String nombre, String monto) {
    return Text.rich(
      TextSpan(
        text: '$nombre ',
        style: Tipografia.texto(15),
        children: [
          TextSpan(text: monto, style: Tipografia.cifra(15, peso: 750)),
        ],
      ),
    );
  }
}
