import 'package:flutter/widgets.dart';

/// Centra [child] y no lo deja crecer más allá de [ancho].
/// Evita que el contenido pensado para teléfono se estire en una tablet.
class AnchoMaximo extends StatelessWidget {
  const AnchoMaximo({super.key, required this.child, this.ancho = 560});

  final Widget child;
  final double ancho;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: ancho),
        child: child,
      ),
    );
  }
}
