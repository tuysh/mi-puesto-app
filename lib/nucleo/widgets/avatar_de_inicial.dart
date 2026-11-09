import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Círculo de color con la inicial de una persona.
class AvatarDeInicial extends StatelessWidget {
  const AvatarDeInicial({
    super.key,
    required this.inicial,
    required this.colores,
    required this.tamano,
  });

  final String inicial;
  final ParDeColores colores;

  /// Diámetro del círculo.
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colores.fondo, shape: BoxShape.circle),
      child: Text(
        inicial,
        // La letra ocupa poco menos de la mitad del círculo.
        style: Tipografia.titulo(
          tamano * 0.47,
          peso: 700,
          color: colores.tinta,
        ),
      ),
    );
  }
}
