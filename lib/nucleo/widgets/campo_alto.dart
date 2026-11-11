import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';
import 'package:mi_puesto/nucleo/widgets/decoracion_de_campo_alto.dart';

/// Un campo de texto "alto" (con el borde oscuro) y su etiqueta encima.
/// Se usa donde el campo es lo principal de la pantalla: el nombre del
/// negocio al crear la cuenta, el nombre de una persona.
class CampoAlto extends StatelessWidget {
  const CampoAlto({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.sugerencia,
    this.maximoDeLetras,
    this.alCambiar,
    this.alEnviar,
  });

  final String etiqueta;
  final TextEditingController controlador;

  /// Texto gris de ejemplo que se ve mientras el campo está vacío.
  final String? sugerencia;

  /// Cuántas letras caben, como mucho; `null` si no hay límite.
  final int? maximoDeLetras;

  final ValueChanged<String>? alCambiar;

  /// Se llama al tocar "Listo" en el teclado.
  final VoidCallback? alEnviar;

  @override
  Widget build(BuildContext context) {
    return CampoEtiquetado(
      etiqueta: etiqueta,
      child: TextField(
        controller: controlador,
        onChanged: alCambiar,
        onSubmitted: alEnviar == null ? null : (_) => alEnviar!(),
        autocorrect: false,
        // Los nombres empiezan con mayúscula sin tener que buscarla.
        textCapitalization: TextCapitalization.words,
        inputFormatters: [
          if (maximoDeLetras != null)
            LengthLimitingTextInputFormatter(maximoDeLetras),
        ],
        style: Tipografia.texto(17, peso: 600),
        decoration: decoracionDeCampoAlto(sugerencia: sugerencia),
      ),
    );
  }
}
