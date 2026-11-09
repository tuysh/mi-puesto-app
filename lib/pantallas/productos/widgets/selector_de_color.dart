import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Una fila de círculos de color para elegir uno. El elegido se marca con
/// borde oscuro y una palomita.
class SelectorDeColor extends StatelessWidget {
  const SelectorDeColor({
    super.key,
    required this.opciones,
    required this.elegido,
    required this.alElegir,
  });

  final List<ParDeColores> opciones;
  final ParDeColores elegido;
  final ValueChanged<ParDeColores> alElegir;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (posicion, opcion) in opciones.indexed)
          _CirculoDeColor(
            colores: opcion,
            estaElegido: opcion == elegido,
            etiqueta: 'Color ${posicion + 1}',
            alTocar: () => alElegir(opcion),
          ),
      ],
    );
  }
}

class _CirculoDeColor extends StatelessWidget {
  const _CirculoDeColor({
    required this.colores,
    required this.estaElegido,
    required this.etiqueta,
    required this.alTocar,
  });

  final ParDeColores colores;
  final bool estaElegido;
  final String etiqueta;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      etiqueta: etiqueta,
      radio: 999,
      decoracion: BoxDecoration(
        color: colores.fondo,
        border: estaElegido ? Border.all(color: Colores.tinta, width: 3) : null,
      ),
      child: SizedBox(
        width: 52,
        height: 52,
        child: estaElegido
            ? Icon(Icons.check_rounded, color: colores.tinta, size: 26)
            : null,
      ),
    );
  }
}
