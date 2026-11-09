import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';

/// Tarjeta pequeña con un dato: una etiqueta y, debajo, su valor en grande.
///
/// Sin [colores] es blanca con borde; con [colores] se pinta de ese color.
class TarjetaDeDato extends StatelessWidget {
  const TarjetaDeDato({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.colores,
  });

  final String etiqueta;
  final String valor;
  final ParDeColores? colores;

  @override
  Widget build(BuildContext context) {
    final colores = this.colores;
    final esBlanca = colores == null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: esBlanca ? Colores.superficie : colores.fondo,
        borderRadius: BorderRadius.circular(Radios.tarjeta),
        border: Border.all(
          // La tarjeta de color lleva un borde de su mismo color para medir
          // exactamente lo mismo que la blanca.
          color: esBlanca ? Colores.borde : colores.fondo,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            etiqueta,
            style: Tipografia.texto(
              14,
              peso: 800,
              color: esBlanca ? Colores.tintaSuave : colores.tinta,
            ),
          ),
          Cifra(
            valor,
            tamano: 32,
            peso: 750,
            color: esBlanca ? Colores.tinta : colores.tinta,
          ),
        ],
      ),
    );
  }
}
