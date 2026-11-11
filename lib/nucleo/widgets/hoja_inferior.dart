import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';

/// Abre [contenido] encima de la pantalla y espera a que se cierre.
/// Devuelve lo que el contenido entregue al cerrarse con
/// `Navigator.of(context).pop(valor)`, o `null` si se canceló.
///
/// En teléfono es una hoja que sube desde abajo; en tablet, un diálogo
/// centrado.
Future<Respuesta?> mostrarHoja<Respuesta>(
  BuildContext context, {
  required Widget contenido,
}) {
  if (esTablet(context)) {
    return showDialog<Respuesta>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colores.superficie,
        child: SizedBox(
          width: 420,
          child: Padding(padding: const EdgeInsets.all(22), child: contenido),
        ),
      ),
    );
  }

  return showModalBottomSheet<Respuesta>(
    context: context,
    backgroundColor: Colores.superficie,
    showDragHandle: true,
    // Permite que la hoja sea tan alta como su contenido.
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        // Cuando sale el teclado, la hoja sube para que no la tape.
        padding: EdgeInsets.fromLTRB(
          18,
          0,
          18,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: contenido,
      ),
    ),
  );
}
