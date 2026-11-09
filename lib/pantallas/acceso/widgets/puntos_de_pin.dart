import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

/// La fila de puntitos que indica cuántos dígitos del PIN se han escrito.
class PuntosDePin extends StatelessWidget {
  const PuntosDePin({super.key, required this.llenos, required this.total});

  /// Cuántos dígitos se han escrito.
  final int llenos;

  /// Cuántos dígitos tiene el PIN completo.
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$llenos de $total',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 18,
        children: [
          for (var posicion = 0; posicion < total; posicion++)
            _Punto(lleno: posicion < llenos),
        ],
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  const _Punto({required this.lleno});

  final bool lleno;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: lleno ? Colores.tinta : null,
        border: Border.all(color: Colores.tinta, width: 3),
      ),
    );
  }
}
