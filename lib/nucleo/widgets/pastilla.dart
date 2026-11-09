import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Etiqueta de color en forma de píldora. Solo informa; no se toca.
class Pastilla extends StatelessWidget {
  const Pastilla({
    super.key,
    required this.texto,
    required this.colores,
    this.alto = 32,
  });

  final String texto;
  final ParDeColores colores;
  final double alto;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: alto,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colores.fondo,
        borderRadius: BorderRadius.circular(Radios.pildora),
      ),
      // widthFactor: 1 hace que la pastilla mida lo que mide su texto, en
      // vez de estirarse a todo el ancho disponible.
      child: Center(
        widthFactor: 1,
        child: Text(
          texto,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Tipografia.texto(14, peso: 800, color: colores.tinta),
        ),
      ),
    );
  }
}
