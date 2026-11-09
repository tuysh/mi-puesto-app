import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/logo_del_puesto.dart';
import 'package:mi_puesto/pantallas/principal/destino.dart';
import 'package:mi_puesto/pantallas/principal/widgets/boton_de_destino.dart';
import 'package:mi_puesto/pantallas/principal/widgets/boton_de_vendedor_actual.dart';

/// El menú de tablet: una columna angosta pegada a la izquierda.
class RielDeNavegacion extends StatelessWidget {
  const RielDeNavegacion({
    super.key,
    required this.destinoActual,
    required this.alElegir,
  });

  final Destino destinoActual;
  final ValueChanged<Destino> alElegir;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        color: Colores.superficie,
        border: Border(right: BorderSide(color: Colores.borde)),
      ),
      child: Column(
        spacing: 6,
        children: [
          const LogoDelPuesto(tamano: 56),
          const SizedBox(height: 4),
          for (final destino in destinosDeTablet)
            BotonDeDestino(
              destino: destino,
              estaElegido: destino == destinoActual,
              alTocar: () => alElegir(destino),
              ancho: 82,
              tamanoDePildora: const Size(64, 36),
              tamanoDeIcono: 26,
            ),
          const Spacer(),
          const BotonDeVendedorActual(),
        ],
      ),
    );
  }
}
