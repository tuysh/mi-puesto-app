import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/error_del_servidor.dart';

/// Muestra un mensaje breve en la parte de abajo de la pantalla.
void mostrarAviso(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mensaje)));
}

/// Avisa que algo falló. Si [error] trae una explicación del servidor
/// ("Ya hay una cuenta con ese correo."), se muestra esa; si no, se muestra
/// [siNoHayExplicacion].
void mostrarAvisoDeError(
  BuildContext context,
  Object error, {
  required String siNoHayExplicacion,
}) {
  final mensaje = error is ErrorDelServidor
      ? error.mensaje
      : siNoHayExplicacion;
  mostrarAviso(context, mensaje);
}
