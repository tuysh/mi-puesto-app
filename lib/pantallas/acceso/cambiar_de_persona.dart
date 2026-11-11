import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_quien_vende.dart';

/// Saca a quien está dentro y vuelve a "¿Quién vende hoy?", para que otra
/// persona escriba su PIN. El pedido a medias se suelta: era de quien sale.
Future<void> cambiarDePersona(BuildContext context) async {
  final dependencias = Dependencias.de(context);

  try {
    await dependencias.sesion.cambiarDePersona();
  } catch (error) {
    if (context.mounted) {
      mostrarAvisoDeError(
        context,
        error,
        siNoHayExplicacion: 'No se pudo cambiar de persona. Intenta otra vez',
      );
    }
    return;
  }

  dependencias.pedido.vaciar();
  dependencias.ventas.cerrarAviso();
  dependencias.caja.olvidar();

  if (!context.mounted) return;
  reemplazarTodasLasPantallas(context, const PantallaQuienVende());
}
