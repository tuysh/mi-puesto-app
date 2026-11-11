import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/hoja_inferior.dart';
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
  return mostrarHoja<ImagenElegida>(
    context,
    contenido: SelectorDeImagen(
      imagenActual: imagenActual,
      nombreDelProducto: nombreDelProducto,
      colores: colores,
    ),
  );
}
