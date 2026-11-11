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
    this.tamanoDeTexto = 14,
    this.rellenoLateral = 12,
  });

  /// Una pastilla chica, para marcar un renglón de una lista: "Editada",
  /// "Cancelada", "Cuadró".
  const Pastilla.chica({super.key, required this.texto, required this.colores})
    : alto = 22,
      tamanoDeTexto = 13,
      rellenoLateral = 8;

  final String texto;
  final ParDeColores colores;
  final double alto;
  final double tamanoDeTexto;
  final double rellenoLateral;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: alto,
      padding: EdgeInsets.symmetric(horizontal: rellenoLateral),
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
          style: Tipografia.texto(
            tamanoDeTexto,
            peso: 800,
            color: colores.tinta,
          ),
        ),
      ),
    );
  }
}
