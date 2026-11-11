import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';

/// Tarjeta chica con un solo número y su nombre arriba: "Gastos $420".
///
/// Sin [colores] es blanca con borde. Con [colores] se pinta de ese color
/// (verde para la utilidad, por ejemplo).
class TarjetaDeDato extends StatelessWidget {
  const TarjetaDeDato({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.colores,
  });

  final String etiqueta;

  /// El número ya convertido a texto, por ejemplo `$420`.
  final String valor;

  final ParDeColores? colores;

  @override
  Widget build(BuildContext context) {
    final colores = this.colores;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colores?.fondo ?? Colores.superficie,
        borderRadius: BorderRadius.circular(Radios.tarjeta),
        // El borde transparente ocupa el mismo sitio que el visible: así
        // las dos variantes miden igual una junto a la otra.
        border: Border.all(
          color: colores == null ? Colores.borde : const Color(0x00000000),
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
              color: colores?.tinta ?? Colores.tintaSuave,
            ),
          ),
          // FittedBox encoge el número si no cabe en media pantalla.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Cifra(
              valor,
              tamano: 30,
              peso: 750,
              color: colores?.tinta ?? Colores.tinta,
            ),
          ),
        ],
      ),
    );
  }
}
