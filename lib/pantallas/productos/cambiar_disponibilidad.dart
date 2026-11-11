import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/avisos.dart';

/// Prende o apaga "Hay hoy" de [producto]. Apagado, el producto se sigue
/// viendo al vender, pero no se puede agregar. Si falla, avisa.
Future<void> cambiarDisponibilidad(
  BuildContext context,
  Producto producto, {
  required bool hayHoy,
}) async {
  try {
    await Dependencias.de(context).catalogo
        .cambiarDisponibilidad(producto, hayHoy);
  } catch (error) {
    if (context.mounted) {
      mostrarAvisoDeError(
        context,
        error,
        siNoHayExplicacion: 'No se pudo cambiar. Intenta otra vez',
      );
    }
  }
}
