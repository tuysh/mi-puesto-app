import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// El recuadro gris que cuenta lo que le pasó a una venta después de
/// registrarla. Cada edición o cancelación deja dicho quién la hizo y
/// cuándo: "Mari la editó hoy a las 2:20 p. m."
class HistorialDeVenta extends StatelessWidget {
  const HistorialDeVenta({super.key, required this.eventos});

  final List<EventoDeVenta> eventos;

  @override
  Widget build(BuildContext context) {
    final sesion = Dependencias.de(context).sesion;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colores.superficieHundida,
        borderRadius: BorderRadius.circular(Radios.tarjeta),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          for (final evento in eventos)
            Text(
              '${sesion.nombreDe(evento.perfilId)} la '
              '${evento.tipo == TipoDeEvento.edicion ? 'editó' : 'canceló'} '
              '${formatearCuando(evento.ocurrioEn)}',
              style: Tipografia.texto(
                14,
                color: Colores.tintaSuave,
                altura: 1.4,
              ),
            ),
        ],
      ),
    );
  }
}
