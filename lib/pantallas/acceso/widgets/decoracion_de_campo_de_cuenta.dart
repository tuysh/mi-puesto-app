import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// El aspecto de los campos de correo y contraseña: más altos que los del
/// resto de la aplicación y con el borde oscuro.
///
/// [alFinal] es lo que va pegado al borde derecho, dentro del campo.
InputDecoration decoracionDeCampoDeCuenta({
  String? sugerencia,
  Widget? alFinal,
}) {
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
