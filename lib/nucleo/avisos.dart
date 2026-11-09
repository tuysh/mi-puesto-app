import 'package:flutter/material.dart';

/// Muestra un mensaje breve en la parte de abajo de la pantalla.
void mostrarAviso(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mensaje)));
}

/// Avisa que una función aparece en el diseño pero todavía no existe.
void mostrarAvisoDePendiente(BuildContext context, String funcion) {
  mostrarAviso(context, '$funcion: disponible próximamente');
}
