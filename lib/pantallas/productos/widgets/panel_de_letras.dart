import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';

/// El campo para escribir las letras del botón de un producto.
class PanelDeLetras extends StatelessWidget {
  const PanelDeLetras({
    super.key,
    required this.controlador,
    required this.alCambiar,
  });

  final TextEditingController controlador;
  final ValueChanged<String> alCambiar;

  /// Cuántas letras caben en el botón.
  static const maximoDeLetras = 2;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder borde(double grosor) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colores.tinta, width: grosor),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        CampoEtiquetado(
          etiqueta: 'Letras del botón',
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 120,
              child: TextField(
                controller: controlador,
                onChanged: alCambiar,
                autocorrect: false,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(maximoDeLetras),
                ],
                style: Tipografia.titulo(26),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colores.superficie,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: borde(2),
                  focusedBorder: borde(3),
                ),
              ),
            ),
          ),
        ),
        Text(
          'Hasta $maximoDeLetras letras. Sirven cuando ningún emoji se '
          'parece a lo que vendes; toman el color de la categoría.',
          style: Tipografia.texto(
            15,
            peso: 600,
            color: Colores.tintaSuave,
            altura: 1.4,
          ),
        ),
      ],
    );
  }
}
