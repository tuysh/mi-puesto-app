import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/widgets/dialogo_de_confirmacion.dart';

/// Elimina [categoria] después de pedir confirmación.
///
/// Una categoría con productos NO se elimina: se avisa que primero hay que
/// pasar sus productos a otra categoría. Así ningún producto se queda sin
/// categoría ni se borra por accidente.
///
/// Devuelve `true` si la categoría quedó eliminada.
Future<bool> eliminarCategoria(
  BuildContext context,
  Categoria categoria,
) async {
  final catalogo = Dependencias.de(context).catalogo;

  final productos = catalogo.cantidadDeProductosEn(categoria);
  if (productos > 0) {
    final palabra = productos == 1 ? 'producto' : 'productos';
    mostrarAviso(
      context,
      'Tiene $productos $palabra. Pásalos a otra categoría antes de eliminarla',
    );
    return false;
  }

  final confirmo = await pedirConfirmacion(
    context,
    titulo: '¿Eliminar ${categoria.nombre}?',
    mensaje: 'Esta categoría ya no aparecerá al vender. No se puede deshacer.',
    textoDeConfirmar: 'Eliminar',
  );
  if (!confirmo) return false;

  try {
    await catalogo.eliminarCategoria(categoria);
    if (context.mounted) mostrarAviso(context, 'Categoría eliminada');
    return true;
  } catch (error) {
    if (context.mounted) {
      mostrarAvisoDeError(
        context,
        error,
        siNoHayExplicacion: 'No se pudo eliminar la categoría',
      );
    }
    return false;
  }
}
