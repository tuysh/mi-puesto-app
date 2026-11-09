import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/reporte.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_de_seccion.dart';
import 'package:mi_puesto/pantallas/reportes/widgets/leyenda_de_grafica.dart';
import 'package:mi_puesto/pantallas/reportes/widgets/par_de_barras.dart';

/// Gráfica de barras: por cada tramo de tiempo, lo vendido y la ganancia.
class GraficaDeVentas extends StatelessWidget {
  const GraficaDeVentas({
    super.key,
    required this.titulo,
    required this.tramos,
  });

  final String titulo;
  final List<TramoDeReporte> tramos;

  /// Lo que mide la barra más alta de la gráfica.
  static const _altoMaximo = 148.0;

  static const _espacioEntreTramos = 10.0;

  @override
  Widget build(BuildContext context) {
    // La barra más alta corresponde al tramo en que más se vendió;
    // todas las demás se dibujan en proporción a esa.
    final mayorVenta = tramos
        .map((tramo) => tramo.vendido.centavos)
        .fold(0, max);

    double altoPara(Dinero monto) {
      if (mayorVenta == 0) return 0;
      return _altoMaximo * monto.centavos / mayorVenta;
    }

    return TarjetaDeSeccion(
      titulo: titulo,
      alLadoDelTitulo: const LeyendaDeGrafica(),
      children: [
        Container(
          height: _altoMaximo + 2,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colores.borde, width: 2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: _espacioEntreTramos,
            children: [
              for (final tramo in tramos)
                Expanded(
                  child: ParDeBarras(
                    altoDeVendido: altoPara(tramo.vendido),
                    altoDeGanancia: altoPara(tramo.ganancia),
                  ),
                ),
            ],
          ),
        ),
        Row(
          spacing: _espacioEntreTramos,
          children: [
            for (final tramo in tramos)
              Expanded(
                child: Text(
                  tramo.etiqueta,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: Tipografia.texto(
                    13,
                    peso: 800,
                    // El tramo actual (hoy) se resalta con tinta oscura.
                    color: tramo.esActual ? Colores.tinta : Colores.tintaSuave,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
