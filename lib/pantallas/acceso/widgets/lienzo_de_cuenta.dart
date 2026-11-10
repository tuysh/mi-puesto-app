import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';

/// El acomodo que comparten "Inicia sesión" y "Crea tu cuenta": el
/// contenido arriba y el [pie] pegado al fondo de la pantalla.
///
/// Si el contenido no cabe (por ejemplo, cuando se abre el teclado), toda
/// la pantalla se puede desplazar y el pie queda al final.
class LienzoDeCuenta extends StatelessWidget {
  const LienzoDeCuenta({
    super.key,
    required this.children,
    required this.pie,
    this.margenDeArriba = 40,
  });

  final List<Widget> children;
  final Widget pie;
  final double margenDeArriba;

  static const _margenDeAbajo = 32.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnchoMaximo(
          ancho: 480,
          child: LayoutBuilder(
            builder: (context, medidas) {
              // El alto que queda para el contenido cuando no hace falta
              // desplazar: con él, el espacio flexible empuja el pie abajo.
              final altoDisponible =
                  medidas.maxHeight - margenDeArriba - _margenDeAbajo;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  margenDeArriba,
                  24,
                  _margenDeAbajo,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: medidas.maxWidth - 48,
                    minHeight: altoDisponible,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 22,
                      children: [...children, const Spacer(), pie],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
