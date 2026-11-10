import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/pantallas/productos/widgets/boton_de_foto.dart';

/// Los dos botones para conseguir la foto de un producto: con la cámara o
/// de la galería.
class PanelDeFoto extends StatelessWidget {
  const PanelDeFoto({
    super.key,
    required this.alPedirFoto,
    required this.estaOcupado,
    this.error,
  });

  /// Recibe `true` para tomar la foto con la cámara y `false` para
  /// elegirla de la galería.
  final ValueChanged<bool> alPedirFoto;

  /// `true` mientras la cámara o la galería están abiertas.
  final bool estaOcupado;

  /// Lo que salió mal al pedir la foto; `null` si todo va bien.
  final String? error;

  @override
  Widget build(BuildContext context) {
    final error = this.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: BotonDeFoto(
                icono: Icons.photo_camera_outlined,
                texto: 'Tomar foto',
                alTocar: estaOcupado ? null : () => alPedirFoto(true),
              ),
            ),
            Expanded(
              child: BotonDeFoto(
                icono: Icons.image_outlined,
                texto: 'Elegir de la galería',
                alTocar: estaOcupado ? null : () => alPedirFoto(false),
              ),
            ),
          ],
        ),
        if (error != null)
          Text(
            error,
            style: Tipografia.texto(
              15,
              peso: 800,
              color: Pasteles.rosa.tinta,
              altura: 1.4,
            ),
          )
        else
          Text(
            'Se recorta sola para llenar el botón. Sale mejor de cerca y '
            'con buena luz.',
            style: Tipografia.texto(
              15,
              peso: 600,
              color: Colores.tintaSuave,
              altura: 1.4,
            ),
          ),
      ],
    );
  }
}
