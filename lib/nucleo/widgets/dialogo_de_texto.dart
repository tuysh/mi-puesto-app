import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_texto.dart';

/// Abre un diálogo que pide un texto y espera la respuesta.
///
/// Devuelve lo que la persona escribió, o `null` si canceló o lo dejó vacío.
Future<String?> pedirTexto(
  BuildContext context, {
  required String titulo,
  String? sugerencia,
  String? prefijo,
  bool esNumero = false,
}) async {
  final respuesta = await showDialog<String>(
    context: context,
    builder: (context) => _DialogoDeTexto(
      titulo: titulo,
      sugerencia: sugerencia,
      prefijo: prefijo,
      esNumero: esNumero,
    ),
  );

  final texto = respuesta?.trim() ?? '';
  return texto.isEmpty ? null : texto;
}

class _DialogoDeTexto extends StatefulWidget {
  const _DialogoDeTexto({
    required this.titulo,
    required this.sugerencia,
    required this.prefijo,
    required this.esNumero,
  });

  final String titulo;
  final String? sugerencia;
  final String? prefijo;
  final bool esNumero;

  @override
  State<_DialogoDeTexto> createState() => _EstadoDeDialogoDeTexto();
}

class _EstadoDeDialogoDeTexto extends State<_DialogoDeTexto> {
  final _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _cancelar() => Navigator.of(context).pop();

  void _aceptar() => Navigator.of(context).pop(_controlador.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo, style: Tipografia.titulo(22)),
      content: CampoDeTexto(
        controlador: _controlador,
        sugerencia: widget.sugerencia,
        prefijo: widget.prefijo,
        esNumero: widget.esNumero,
        enfocarAlAbrir: true,
      ),
      actions: [
        BotonDeEnlace(texto: 'Cancelar', alTocar: _cancelar),
        BotonPrincipal(
          texto: 'Aceptar',
          alTocar: _aceptar,
          alto: 48,
          tamanoDeTexto: 17,
        ),
      ],
    );
  }
}
