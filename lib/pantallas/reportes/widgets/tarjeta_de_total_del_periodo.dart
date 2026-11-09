import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/reporte.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/nucleo/widgets/cifra_con_doble_raya.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_elevada.dart';

/// El total vendido en el periodo y, a un lado, la ganancia.
class TarjetaDeTotalDelPeriodo extends StatelessWidget {
  const TarjetaDeTotalDelPeriodo({super.key, required this.reporte});

  final Reporte reporte;

  @override
  Widget build(BuildContext context) {
    return TarjetaElevada(
      relleno: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  reporte.periodo.tituloDelTotal,
                  style: Tipografia.texto(
                    15,
                    peso: 800,
                    color: Colores.tintaSuave,
                  ),
                ),
                // FittedBox encoge la cifra si es tan larga que no cabe.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: CifraConDobleRaya(
                    formatearDinero(reporte.vendido),
                    tamano: 46,
                  ),
                ),
              ],
            ),
          ),
          _EtiquetaDeGanancia(ganancia: formatearDinero(reporte.ganancia)),
        ],
      ),
    );
  }
}

class _EtiquetaDeGanancia extends StatelessWidget {
  const _EtiquetaDeGanancia({required this.ganancia});

  final String ganancia;

  @override
  Widget build(BuildContext context) {
    const verde = Colores.exito;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: verde.fondo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 2,
        children: [
          Text(
            'Ganancia',
            style: Tipografia.texto(13, peso: 800, color: verde.tinta),
          ),
          Cifra(ganancia, tamano: 24, peso: 750, color: verde.tinta),
        ],
      ),
    );
  }
}
