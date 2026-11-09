import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Coloca una etiqueta en negritas encima de un campo.
class CampoEtiquetado extends StatelessWidget {
  const CampoEtiquetado({
    super.key,
    required this.etiqueta,
    required this.child,
    this.tamanoDeEtiqueta = 15,
  });

  final String etiqueta;

  /// El campo que va debajo de la etiqueta.
  final Widget child;

  final double tamanoDeEtiqueta;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Text(etiqueta, style: Tipografia.texto(tamanoDeEtiqueta, peso: 800)),
        child,
      ],
    );
  }
}
