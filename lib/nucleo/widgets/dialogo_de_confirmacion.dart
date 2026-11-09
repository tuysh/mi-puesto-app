import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';

/// Abre un diálogo que pregunta antes de hacer algo que no se puede
/// deshacer. Devuelve `true` solo si la persona tocó el botón de confirmar.
Future<bool> pedirConfirmacion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String textoDeConfirmar,
}) async {
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo, style: Tipografia.titulo(22)),
      content: Text(
        mensaje,
        style: Tipografia.texto(16, peso: 600, color: Colores.tintaSuave),
      ),
      actions: [
        BotonDeEnlace(
          texto: 'Cancelar',
          alTocar: () => Navigator.of(context).pop(false),
        ),
        BotonPrincipal(
          texto: textoDeConfirmar,
          alto: 48,
          tamanoDeTexto: 17,
          alTocar: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  // Si se cerró tocando fuera del diálogo, la respuesta es `null`.
  return respuesta ?? false;
}
