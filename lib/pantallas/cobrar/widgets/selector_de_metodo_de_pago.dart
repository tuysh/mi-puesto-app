import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/widgets/selector_de_segmentos.dart';

/// Los dos botones para decir cómo pagó el cliente: "Efectivo" o
/// "Tarjeta". Con tarjeta solo se anota el método: no hay billetes ni
/// cambio.
class SelectorDeMetodoDePago extends StatelessWidget {
  const SelectorDeMetodoDePago({
    super.key,
    required this.elegido,
    required this.alElegir,
    this.grande = true,
  });

  final MetodoDePago elegido;
  final ValueChanged<MetodoDePago> alElegir;

  /// Con `false` los botones son un poco más bajitos (panel de tablet).
  final bool grande;

  @override
  Widget build(BuildContext context) {
    final opciones = {
      for (final metodo in MetodoDePago.values) metodo: metodo.etiqueta,
    };

    if (grande) {
      return SelectorDeSegmentos<MetodoDePago>.grande(
        opciones: opciones,
        elegida: elegido,
        alElegir: alElegir,
      );
    }
    return SelectorDeSegmentos<MetodoDePago>(
      opciones: opciones,
      elegida: elegido,
      alElegir: alElegir,
    );
  }
}
