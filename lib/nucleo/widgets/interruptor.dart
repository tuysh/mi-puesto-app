import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';

/// Interruptor de encendido/apagado: verde cuando está activo.
class Interruptor extends StatelessWidget {
  const Interruptor({
    super.key,
    required this.activo,
    required this.alCambiar,
    required this.etiqueta,
  });

  final bool activo;

  /// Recibe el valor nuevo: `true` si se acaba de encender.
  final ValueChanged<bool> alCambiar;

  /// Texto para lectores de pantalla, por ejemplo "A la venta".
  final String etiqueta;

  static const _duracion = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: activo,
      label: etiqueta,
      child: GestureDetector(
        onTap: () => alCambiar(!activo),
        child: AnimatedContainer(
          duration: _duracion,
          width: 52,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: activo ? Colores.exito.tinta : Colores.bordePunteado,
            borderRadius: BorderRadius.circular(Radios.pildora),
          ),
          // La perilla blanca se desliza a la derecha al encender.
          child: AnimatedAlign(
            duration: _duracion,
            alignment: activo ? Alignment.centerRight : Alignment.centerLeft,
            child: const _Perilla(),
          ),
        ),
      ),
    );
  }
}

class _Perilla extends StatelessWidget {
  const _Perilla();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Colores.superficie,
        shape: BoxShape.circle,
      ),
    );
  }
}
