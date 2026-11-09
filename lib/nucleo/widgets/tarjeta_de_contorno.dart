import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';

/// Tarjeta blanca con borde claro y sin sombra: para información secundaria.
class TarjetaDeContorno extends StatelessWidget {
  const TarjetaDeContorno({
    super.key,
    required this.child,
    this.relleno = const EdgeInsets.all(16),
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
        borderRadius: BorderRadius.circular(Radios.tarjeta),
        border: Border.all(color: Colores.borde, width: 2),
      ),
      child: child,
    );
  }
}
