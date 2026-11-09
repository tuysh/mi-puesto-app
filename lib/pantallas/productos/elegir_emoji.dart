import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/pantallas/productos/widgets/selector_de_emoji.dart';

/// Abre el selector de emoji y espera a que la persona elija uno.
///
/// En teléfono es una hoja que sube desde abajo; en tablet, un diálogo
/// centrado. Devuelve el emoji elegido, o `null` si se canceló.
Future<String?> elegirEmoji(
  BuildContext context, {
  required String emojiActual,
  required String nombreDelProducto,
  required Color fondo,
}) {
  final selector = SelectorDeEmoji(
    emojiActual: emojiActual,
    nombreDelProducto: nombreDelProducto,
    fondo: fondo,
  );

  if (esTablet(context)) {
    return showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colores.superficie,
        child: SizedBox(
          width: 420,
          child: Padding(padding: const EdgeInsets.all(22), child: selector),
        ),
      ),
    );
  }

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colores.superficie,
    showDragHandle: true,
    // Permite que la hoja sea tan alta como su contenido.
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: selector,
      ),
    ),
  );
}
