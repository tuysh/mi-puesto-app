import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Explica qué significa cada color de barra en la gráfica.
class LeyendaDeGrafica extends StatelessWidget {
  const LeyendaDeGrafica({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        _Clave(color: Colores.tinta, texto: 'Vendido'),
        _Clave(color: Colores.barraDeGanancia, texto: 'Ganancia'),
      ],
    );
  }
}

/// Un cuadrito de color con su significado al lado.
class _Clave extends StatelessWidget {
  const _Clave({required this.color, required this.texto});

  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        Text(texto, style: Tipografia.texto(13, peso: 800)),
      ],
    );
  }
}
