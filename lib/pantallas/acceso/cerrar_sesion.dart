import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/dialogo_de_confirmacion.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_de_iniciar_sesion.dart';

/// Pregunta si de verdad se quiere salir de la cuenta y, si la respuesta es
/// sí, cierra la sesión y vuelve a "Inicia sesión".
///
/// Se pregunta antes porque para volver a entrar hace falta la contraseña,
/// y quien vende normalmente solo conoce el PIN.
Future<void> cerrarSesion(BuildContext context) async {
  final dependencias = Dependencias.de(context);

  final confirmo = await pedirConfirmacion(
    context,
    titulo: '¿Cerrar sesión?',
    mensaje:
        'Para volver a entrar vas a necesitar el correo y la contraseña '
        'de la cuenta.',
    textoDeConfirmar: 'Cerrar sesión',
  );
  if (!confirmo) return;

  try {
    await dependencias.sesion.cerrarSesion();
  } catch (error) {
    if (context.mounted) {
      mostrarAvisoDeError(
        context,
        error,
        siNoHayExplicacion: 'No se pudo cerrar la sesión',
      );
    }
    return;
  }

  // Lo que quedó a medias era de la cuenta que acaba de salir.
  dependencias.pedido.vaciar();
  dependencias.ventas.cerrarAviso();

  if (!context.mounted) return;
  reemplazarTodasLasPantallas(context, const PantallaDeIniciarSesion());
}
