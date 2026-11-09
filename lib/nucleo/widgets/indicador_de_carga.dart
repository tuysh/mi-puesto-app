import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Rueda giratoria centrada, mientras llegan los datos.
class IndicadorDeCarga extends StatelessWidget {
  const IndicadorDeCarga({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(color: Colores.tinta),
      ),
    );
  }
}
