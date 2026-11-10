import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// El título grande de las pantallas de cuenta y, debajo, un párrafo que
/// explica para qué sirve la cuenta.
class EncabezadoDeCuenta extends StatelessWidget {
  const EncabezadoDeCuenta({
    super.key,
    required this.titulo,
    required this.explicacion,
  });

  final String titulo;
  final String explicacion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(titulo, style: Tipografia.titulo(34)),
        Text(
          explicacion,
          style: Tipografia.texto(
            17,
            peso: 600,
            color: Colores.tintaSuave,
            altura: 1.35,
          ),
        ),
      ],
    );
  }
}
