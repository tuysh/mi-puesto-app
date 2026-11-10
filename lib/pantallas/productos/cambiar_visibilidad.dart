import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/avisos.dart';

/// Pone [producto] a la venta o lo oculta, y guarda el cambio.
/// Si falla, avisa en pantalla.
Future<void> cambiarVisibilidad(
  BuildContext context,
  Producto producto, {
  required bool aLaVenta,
}) async {
  final catalogo = Dependencias.de(context).catalogo;

  try {
    await catalogo.guardarProducto(producto.copiarCon(aLaVenta: aLaVenta));
  } catch (error) {
    if (context.mounted) {
      mostrarAvisoDeError(
        context,
        error,
        siNoHayExplicacion: 'No se pudo guardar el cambio',
      );
    }
  }
}
