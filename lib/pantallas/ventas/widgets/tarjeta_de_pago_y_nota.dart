import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_de_contorno.dart';

/// En el detalle de una venta: con qué se pagó y, si tiene, su nota.
class TarjetaDePagoYNota extends StatelessWidget {
  const TarjetaDePagoYNota({super.key, required this.venta});

  final Venta venta;

  @override
  Widget build(BuildContext context) {
    return TarjetaDeContorno(
      relleno: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        spacing: 8,
        children: [
          _construirRenglon('Pagó con', venta.metodoDePago.etiqueta),
          if (venta.nota.isNotEmpty) _construirRenglon('Nota', venta.nota),
        ],
      ),
    );
  }

  Widget _construirRenglon(String concepto, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(concepto, style: Tipografia.texto(16, color: Colores.tintaSuave)),
        Expanded(
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: Tipografia.texto(16),
          ),
        ),
      ],
    );
  }
}
