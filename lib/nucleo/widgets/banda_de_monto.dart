import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';

/// Franja de color con una etiqueta a la izquierda y un monto grande a la
/// derecha: "Cambio $75", "Falta dinero $5", "Ganas por pieza $27".
class BandaDeMonto extends StatelessWidget {
  const BandaDeMonto({
    super.key,
    required this.etiqueta,
    required this.monto,
    this.detalle,
    this.colores = Colores.exito,
    this.tamanoDeMonto = 44,
  });

  final String etiqueta;

  /// El monto ya convertido a texto, por ejemplo `$75`.
  final String monto;

  /// Renglón opcional, más pequeño, debajo de la etiqueta.
  final String? detalle;

  final ParDeColores colores;
  final double tamanoDeMonto;

  @override
  Widget build(BuildContext context) {
    final detalle = this.detalle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: colores.fondo,
        borderRadius: BorderRadius.circular(Radios.tarjeta),
      ),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: Tipografia.texto(17, peso: 800, color: colores.tinta),
                ),
                if (detalle != null)
                  Text(
                    detalle,
                    style: Tipografia.texto(14, color: colores.tinta),
                  ),
              ],
            ),
          ),
          Cifra(monto, tamano: tamanoDeMonto, peso: 750, color: colores.tinta),
        ],
      ),
    );
  }
}
