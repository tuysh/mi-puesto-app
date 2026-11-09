import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';

/// Circulito oscuro con un número: cuántas piezas lleva el pedido.
class InsigniaDeCantidad extends StatelessWidget {
  const InsigniaDeCantidad({super.key, required this.cantidad});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      constraints: const BoxConstraints(minWidth: 30),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colores.tinta,
        borderRadius: BorderRadius.circular(Radios.pildora),
        // El borde del color del fondo la separa visualmente de la tesela.
        border: Border.all(
          color: Colores.fondo,
          width: 3,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Cifra('$cantidad', tamano: 15, color: Colores.superficie),
    );
  }
}
