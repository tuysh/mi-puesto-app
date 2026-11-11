import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_texto.dart';

/// El campo para anotar algo de la venta: "sin hielo", "para llevar".
/// Es opcional.
class CampoDeNota extends StatelessWidget {
  const CampoDeNota({super.key, required this.controlador});

  final TextEditingController controlador;

  /// Lo más larga que acepta el servidor una nota.
  static const largoMaximo = 200;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Nota de la venta',
      child: CampoDeTexto(
        controlador: controlador,
        sugerencia: 'Nota (opcional). Ej. sin hielo',
        maximoDeLetras: largoMaximo,
      ),
    );
  }
}
