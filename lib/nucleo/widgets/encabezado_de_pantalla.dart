import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// El título grande de una pantalla, con un renglón pequeño opcional arriba
/// (el nombre del puesto o la fecha).
class EncabezadoDePantalla extends StatelessWidget {
  const EncabezadoDePantalla({
    super.key,
    required this.titulo,
    this.sobretitulo,
    this.tamanoDeTitulo = 32,
  });

  final String titulo;
  final String? sobretitulo;
  final double tamanoDeTitulo;

  @override
  Widget build(BuildContext context) {
    final sobretitulo = this.sobretitulo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        if (sobretitulo != null)
          Text(
            sobretitulo,
            style: Tipografia.texto(15, color: Colores.tintaSuave),
          ),
        Text(titulo, style: Tipografia.titulo(tamanoDeTitulo)),
      ],
    );
  }
}
