import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Encabezado de las pantallas que se abren encima de otra: una flecha para
/// volver, el título y, si hace falta, un renglón pequeño debajo.
class EncabezadoConVolver extends StatelessWidget {
  const EncabezadoConVolver({super.key, required this.titulo, this.subtitulo});

  final String titulo;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    final subtitulo = this.subtitulo;

    return Row(
      children: [
        IconButton(
          tooltip: 'Volver',
          onPressed: () => cerrarPantalla(context),
          icon: const Icon(Icons.chevron_left_rounded, size: 32),
          color: Colores.tinta,
          padding: EdgeInsets.zero,
        ),
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
      ],
    );
  }
}
