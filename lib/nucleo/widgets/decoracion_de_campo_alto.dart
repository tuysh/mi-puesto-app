import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// El aspecto de los campos "altos": los de correo y contraseña y los del
/// nombre de una persona. Miden más que los del resto de la aplicación y
/// llevan el borde oscuro.
///
/// [alFinal] es lo que va pegado al borde derecho, dentro del campo.
InputDecoration decoracionDeCampoAlto({String? sugerencia, Widget? alFinal}) {
  OutlineInputBorder borde(double grosor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Colores.tinta, width: grosor),
    );
  }

  return InputDecoration(
    hintText: sugerencia,
    hintStyle: Tipografia.texto(17, peso: 600, color: Colores.tintaSuave),
    filled: true,
    fillColor: Colores.superficie,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    suffixIcon: alFinal,
    enabledBorder: borde(2),
    focusedBorder: borde(3),
  );
}
