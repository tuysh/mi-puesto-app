import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';

/// El marco de las pantallas que se abren encima de otra (Cobrar, Gastos,
/// Editar producto…): el fondo, los márgenes y un ancho máximo para que en
/// tablet el contenido no se estire.
class MarcoDePantalla extends StatelessWidget {
  const MarcoDePantalla({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnchoMaximo(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: child,
          ),
        ),
      ),
    );
  }
}
