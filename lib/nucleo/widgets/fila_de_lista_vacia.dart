import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Renglón gris para cuando una lista no tiene nada que mostrar.
class FilaDeListaVacia extends StatelessWidget {
  const FilaDeListaVacia(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: Tipografia.texto(15, peso: 600, color: Colores.tintaSuave),
      ),
    );
  }
}
