import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Campo para escribir, con borde redondeado.
class CampoDeTexto extends StatelessWidget {
  const CampoDeTexto({
    super.key,
    required this.controlador,
    this.sugerencia,
    this.prefijo,
    this.esNumero = false,
    this.estilo,
    this.alCambiar,
    this.enfocarAlAbrir = false,
    this.maximoDeLetras,
    this.alEnviar,
  });

  final TextEditingController controlador;

  /// Texto gris de ejemplo que se ve mientras el campo está vacío.
  final String? sugerencia;

  /// Texto fijo al inicio del campo, por ejemplo `$`.
  final String? prefijo;

  /// Si es `true` se abre el teclado numérico.
  final bool esNumero;

  /// Estilo de lo que se escribe; si es `null` usa el estilo normal.
  final TextStyle? estilo;

  final ValueChanged<String>? alCambiar;

  /// Si es `true` el teclado se abre solo al mostrarse el campo.
  final bool enfocarAlAbrir;

  /// Cuántas letras caben, como mucho; `null` si no hay límite.
  final int? maximoDeLetras;

  /// Se llama al tocar "Listo" en el teclado.
  final VoidCallback? alEnviar;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controlador,
      onChanged: alCambiar,
      autofocus: enfocarAlAbrir,
      autocorrect: false,
      onSubmitted: alEnviar == null ? null : (_) => alEnviar!(),
      // Los nombres empiezan con mayúscula sin tener que buscarla.
      textCapitalization: TextCapitalization.sentences,
      inputFormatters: [
        if (maximoDeLetras != null)
          LengthLimitingTextInputFormatter(maximoDeLetras),
      ],
      keyboardType: esNumero
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: estilo ?? Tipografia.texto(17, peso: 600),
      decoration: decoracionDeCampo(sugerencia: sugerencia, prefijo: prefijo),
    );
  }
}

/// El aspecto de los campos de texto y de las listas desplegables.
InputDecoration decoracionDeCampo({String? sugerencia, String? prefijo}) {
  OutlineInputBorder borde(Color color, double grosor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radios.campo),
      borderSide: BorderSide(color: color, width: grosor),
    );
  }

  return InputDecoration(
    hintText: sugerencia,
    hintStyle: Tipografia.texto(17, peso: 600, color: Colores.tintaSuave),
    prefixText: prefijo,
    prefixStyle: Tipografia.cifra(18, color: Colores.tintaSuave),
    filled: true,
    fillColor: Colores.superficie,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: borde(Colores.bordeDeCampo, 2),
    focusedBorder: borde(Colores.tinta, 3),
  );
}
