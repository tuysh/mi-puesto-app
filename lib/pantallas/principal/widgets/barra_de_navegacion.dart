import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/pantallas/principal/destino.dart';
import 'package:mi_puesto/pantallas/principal/widgets/boton_de_destino.dart';

/// El menú de teléfono: una barra en la parte de abajo de la pantalla.
class BarraDeNavegacion extends StatelessWidget {
  const BarraDeNavegacion({
    super.key,
    required this.destinos,
    required this.destinoActual,
    required this.alElegir,
  });

  /// Las secciones que puede ver quien está dentro.
  final List<Destino> destinos;

  final Destino destinoActual;
  final ValueChanged<Destino> alElegir;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colores.superficie,
        border: Border(top: BorderSide(color: Colores.borde)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final destino in destinos)
                BotonDeDestino(
                  destino: destino,
                  estaElegido: destino == destinoActual,
                  alTocar: () => alElegir(destino),
                  // Con solo dos botones, cada uno puede ser más ancho.
                  ancho: destinos.length > 2 ? 72 : 96,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
