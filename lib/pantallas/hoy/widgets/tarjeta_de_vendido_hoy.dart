import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra_con_doble_raya.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_elevada.dart';

/// La cifra más importante del día: cuánto se ha vendido.
class TarjetaDeVendidoHoy extends StatelessWidget {
  const TarjetaDeVendidoHoy({super.key, required this.vendido});

  final Dinero vendido;

  @override
  Widget build(BuildContext context) {
    return TarjetaElevada(
      relleno: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(
            'Vendido hoy',
            style: Tipografia.texto(15, peso: 800, color: Colores.tintaSuave),
          ),
          CifraConDobleRaya(formatearDinero(vendido), tamano: 56),
        ],
      ),
    );
  }
}
