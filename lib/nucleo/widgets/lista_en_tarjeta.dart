import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';

/// Una tarjeta de contorno con varios renglones, separados por una raya
/// delgada: las ventas del día, los gastos, las opciones de "Más"…
///
/// Mide lo que miden sus renglones. Si son muchos, quien la usa la mete en
/// algo que se desplace.
class ListaEnTarjeta extends StatelessWidget {
  const ListaEnTarjeta({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Recorta los renglones a las esquinas redondeadas, para que el
      // brillo al tocar el primero y el último no se salga.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colores.superficie,
        borderRadius: BorderRadius.circular(Radios.tarjeta),
        border: Border.all(color: Colores.borde, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (posicion, renglon) in children.indexed) ...[
            if (posicion > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: Colores.superficieHundida,
              ),
            renglon,
          ],
        ],
      ),
    );
  }
}
