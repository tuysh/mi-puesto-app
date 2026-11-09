import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/nucleo/widgets/cuadro_de_emoji.dart';
import 'package:mi_puesto/pantallas/hoy/widgets/barra_de_proporcion.dart';

/// Un producto de "Lo más vendido": emoji, nombre, piezas vendidas y una
/// barra que lo compara con el producto más vendido.
class RenglonDeMasVendido extends StatelessWidget {
  const RenglonDeMasVendido({
    super.key,
    required this.emoji,
    required this.fondoDelEmoji,
    required this.nombre,
    required this.piezas,
    required this.fraccion,
  });

  final String emoji;
  final Color fondoDelEmoji;
  final String nombre;
  final int piezas;

  /// Qué tan llena va la barra: 1 para el producto más vendido.
  final double fraccion;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        CuadroDeEmoji(emoji: emoji, fondo: fondoDelEmoji),
        Expanded(
          child: Column(
            spacing: 5,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(nombre, style: Tipografia.texto(15, peso: 800)),
                  ),
                  Cifra('$piezas pzs', tamano: 15),
                ],
              ),
              BarraDeProporcion(fraccion: fraccion),
            ],
          ),
        ),
      ],
    );
  }
}
