import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/pantallas/productos/imagen_elegida.dart';
import 'package:mi_puesto/pantallas/productos/widgets/selector_de_imagen.dart';

/// Abre "¿Cómo se ve al vender?" y espera a que la persona elija cómo se
/// ve el producto: con un emoji, con letras o con una foto.
///
/// En teléfono es una hoja que sube desde abajo; en tablet, un diálogo
/// centrado. Devuelve lo elegido, o `null` si se canceló.
Future<ImagenElegida?> elegirImagen(
  BuildContext context, {
  required ImagenElegida imagenActual,
  required String nombreDelProducto,
  required ParDeColores colores,
}) {
  final selector = SelectorDeImagen(
    imagenActual: imagenActual,
    nombreDelProducto: nombreDelProducto,
    colores: colores,
  );

  if (esTablet(context)) {
    return showDialog<ImagenElegida>(
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

  return showModalBottomSheet<ImagenElegida>(
    context: context,
    backgroundColor: Colores.superficie,
    showDragHandle: true,
    // Permite que la hoja sea tan alta como su contenido.
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        // Cuando sale el teclado (para escribir las letras), la hoja sube
        // para que no la tape.
        padding: EdgeInsets.fromLTRB(
          18,
          0,
          18,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: selector,
      ),
    ),
  );
}
