import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/cifra_con_doble_raya.dart';
import 'package:mi_puesto/nucleo/widgets/linea_punteada.dart';
import 'package:mi_puesto/nucleo/widgets/renglon_de_monto.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_elevada.dart';

/// La cuenta del pedido al cobrar: un renglón por producto, el total con
/// doble raya y el enlace para volver a cambiar los productos.
class TarjetaDePedido extends StatelessWidget {
  const TarjetaDePedido({
    super.key,
    required this.lineas,
    required this.total,
    required this.alCambiarProductos,
  });

  final List<LineaDePedido> lineas;
  final Dinero total;
  final VoidCallback alCambiarProductos;

  @override
  Widget build(BuildContext context) {
    return TarjetaElevada(
      relleno: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          for (final linea in lineas)
            RenglonDeMonto(
              concepto: '${linea.cantidad} × ${linea.producto.nombreCorto}',
              monto: formatearDinero(linea.subtotal),
            ),
          const LineaPunteada(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Tipografia.texto(18, peso: 800)),
              CifraConDobleRaya(formatearDinero(total), tamano: 52),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: BotonDeEnlace(
              texto: 'Cambiar productos',
              icono: Icons.edit_outlined,
              alTocar: alCambiarProductos,
            ),
          ),
        ],
      ),
    );
  }
}
