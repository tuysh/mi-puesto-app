import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_volver.dart';

/// Encabezado de las pantallas que se abren encima de otra: una flecha para
/// volver, el título y, si hace falta, un renglón pequeño debajo.
class EncabezadoConVolver extends StatelessWidget {
  const EncabezadoConVolver({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.accion,
  });

  final String titulo;
  final String? subtitulo;

  /// Lo que va pegado a la derecha, por ejemplo el enlace "Vaciar".
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final subtitulo = this.subtitulo;

    return Row(
      spacing: 4,
      children: [
        BotonDeVolver(alTocar: () => cerrarPantalla(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: Tipografia.titulo(28)),
              if (subtitulo != null)
                Text(
                  subtitulo,
                  style: Tipografia.texto(14, color: Colores.tintaSuave),
                ),
            ],
          ),
        ),
        ?accion,
      ],
    );
  }
}
