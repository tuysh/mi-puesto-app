import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';
import 'package:mi_puesto/nucleo/widgets/decoracion_de_campo_alto.dart';

/// El campo "Contraseña": lo escrito se ve como puntitos hasta que se toca
/// "Mostrar".
class CampoDeContrasena extends StatefulWidget {
  const CampoDeContrasena({
    super.key,
    required this.controlador,
    required this.alEnviar,
    this.esNueva = false,
    this.ayuda,
  });

  final TextEditingController controlador;

  /// Se llama al tocar "Listo" en el teclado.
  final VoidCallback alEnviar;

  /// `true` al crear la cuenta y `false` al iniciar sesión. Sirve para que
  /// el teléfono ofrezca guardar la contraseña o rellenarla.
  final bool esNueva;

  /// Renglón gris debajo del campo, por ejemplo cuántos caracteres pide.
  final String? ayuda;

  @override
  State<CampoDeContrasena> createState() => _EstadoDeCampoDeContrasena();
}

class _EstadoDeCampoDeContrasena extends State<CampoDeContrasena> {
  bool _seVe = false;

  @override
  Widget build(BuildContext context) {
    final ayuda = widget.ayuda;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        CampoEtiquetado(
          etiqueta: 'Contraseña',
          child: TextField(
            controller: widget.controlador,
            obscureText: !_seVe,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => widget.alEnviar(),
            autofillHints: [
              widget.esNueva
                  ? AutofillHints.newPassword
                  : AutofillHints.password,
            ],
            autocorrect: false,
            enableSuggestions: false,
            style: Tipografia.texto(17, peso: 600),
            decoration: decoracionDeCampoAlto(
              alFinal: Padding(
                padding: const EdgeInsets.only(left: 4, right: 10),
                child: BotonDeEnlace(
                  texto: _seVe ? 'Ocultar' : 'Mostrar',
                  alTocar: () => setState(() => _seVe = !_seVe),
                ),
              ),
            ),
          ),
        ),
        if (ayuda != null)
          Text(ayuda, style: Tipografia.texto(14, color: Colores.tintaSuave)),
      ],
    );
  }
}
