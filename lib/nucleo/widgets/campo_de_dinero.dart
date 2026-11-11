import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';

/// Campo grande para escribir una cantidad de dinero, con el signo de pesos
/// fijo a la izquierda. Es la pregunta principal de su pantalla: "¿Con
/// cuánto abres?", "¿Cuánto contaste?", "¿Cuánto se gastó?".
class CampoDeDinero extends StatelessWidget {
  const CampoDeDinero({
    super.key,
    required this.controlador,
    this.alCambiar,
    this.enfocarAlAbrir = false,
  });

  final TextEditingController controlador;
  final ValueChanged<String>? alCambiar;

  /// Si es `true` el teclado se abre solo al mostrarse el campo.
  final bool enfocarAlAbrir;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colores.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colores.tinta, width: 2),
      ),
      child: Row(
        spacing: 6,
        children: [
          const Cifra('\$', tamano: 26, color: Colores.tintaSuave),
          Expanded(
            child: TextField(
              controller: controlador,
              onChanged: alCambiar,
              autofocus: enfocarAlAbrir,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: Tipografia.cifra(30, peso: 750),
              // "collapsed" quita el borde propio del TextField; el borde
              // ya lo dibuja el Container de afuera.
              decoration: InputDecoration.collapsed(
                hintText: '0',
                hintStyle: Tipografia.cifra(
                  30,
                  peso: 750,
                  color: Colores.bordePunteado,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
