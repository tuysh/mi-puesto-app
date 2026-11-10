import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/decoracion_de_campo_de_cuenta.dart';

/// El campo "Correo" de las pantallas de cuenta.
class CampoDeCorreo extends StatelessWidget {
  const CampoDeCorreo({super.key, required this.controlador, this.sugerencia});

  final TextEditingController controlador;

  /// Texto gris de ejemplo que se ve mientras el campo está vacío.
  final String? sugerencia;

  @override
  Widget build(BuildContext context) {
    return CampoEtiquetado(
      etiqueta: 'Correo',
      child: TextField(
        controller: controlador,
        keyboardType: TextInputType.emailAddress,
        // "Siguiente" en el teclado pasa a la contraseña.
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.email],
        autocorrect: false,
        enableSuggestions: false,
        style: Tipografia.texto(17, peso: 600),
        decoration: decoracionDeCampoDeCuenta(sugerencia: sugerencia),
      ),
    );
  }
}
