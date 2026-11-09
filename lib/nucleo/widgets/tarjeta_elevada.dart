import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';

/// Tarjeta blanca con sombra dura: para lo más importante de la pantalla.
class TarjetaElevada extends StatelessWidget {
  const TarjetaElevada({
    super.key,
    required this.child,
    this.relleno = const EdgeInsets.all(18),
  });

  final Widget child;

  /// Espacio entre el borde de la tarjeta y su contenido.
  final EdgeInsets relleno;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: relleno,
      decoration: BoxDecoration(
        color: Colores.superficie,
        borderRadius: BorderRadius.circular(Radios.tarjetaGrande),
        boxShadow: Sombras.dura(),
      ),
      child: child,
    );
  }
}
