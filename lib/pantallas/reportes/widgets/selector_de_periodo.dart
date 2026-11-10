import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/reporte.dart';
import 'package:mi_puesto/nucleo/widgets/selector_de_segmentos.dart';

/// Los tres botones juntos para elegir Día, Semana o Mes.
class SelectorDePeriodo extends StatelessWidget {
  const SelectorDePeriodo({
    super.key,
    required this.elegido,
    required this.alElegir,
  });

  final Periodo elegido;
  final ValueChanged<Periodo> alElegir;

  @override
  Widget build(BuildContext context) {
    return SelectorDeSegmentos<Periodo>(
      opciones: {
        for (final periodo in Periodo.values) periodo: periodo.etiqueta,
      },
      elegida: elegido,
      alElegir: alElegir,
    );
  }
}
