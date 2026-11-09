import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/pantallas/principal/destino.dart';
import 'package:mi_puesto/pantallas/principal/widgets/boton_de_destino.dart';

/// El menú de teléfono: una barra en la parte de abajo de la pantalla.
class BarraDeNavegacion extends StatelessWidget {
  const BarraDeNavegacion({
    super.key,
    required this.destinoActual,
    required this.alElegir,
  });

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
              for (final destino in destinosDeTelefono)
                BotonDeDestino(
                  destino: destino,
                  estaElegido: _estaElegido(destino),
                  alTocar: () => alElegir(destino),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _estaElegido(Destino destino) {
    // Las secciones que no tienen botón propio (Historial, Productos)
    // se abren desde "Más", así que encienden ese botón.
    final actualTieneBoton = destinosDeTelefono.contains(destinoActual);
    if (!actualTieneBoton) return destino == Destino.mas;

    return destino == destinoActual;
  }
}
