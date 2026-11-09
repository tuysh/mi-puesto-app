import 'package:flutter/material.dart';

/// Una caja decorada (color, borde, sombra) que responde al toque.
///
/// Es la base de casi todos los botones de la aplicación. Si [alTocar] es
/// `null`, la caja se ve igual pero no responde.
class CajaTocable extends StatelessWidget {
  const CajaTocable({
    super.key,
    required this.child,
    required this.alTocar,
    this.decoracion = const BoxDecoration(),
    this.radio = 0,
    this.etiqueta,
  });

  final Widget child;
  final VoidCallback? alTocar;
  final BoxDecoration decoracion;

  /// Radio de las esquinas redondeadas.
  final double radio;

  /// Texto que leen los lectores de pantalla. Si es `null`, leen el
  /// contenido de la caja.
  final String? etiqueta;

  @override
  Widget build(BuildContext context) {
    final esquinas = BorderRadius.circular(radio);

    return Semantics(
      button: true,
      label: etiqueta,
      child: DecoratedBox(
        decoration: decoracion.copyWith(borderRadius: esquinas),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(borderRadius: esquinas, onTap: alTocar, child: child),
        ),
      ),
    );
  }
}
