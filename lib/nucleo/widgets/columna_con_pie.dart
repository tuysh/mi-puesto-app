import 'package:flutter/widgets.dart';

/// Una columna que se puede desplazar, con un [pie] que siempre queda fijo
/// en la parte de abajo (normalmente el botón principal de la pantalla).
class ColumnaConPie extends StatelessWidget {
  const ColumnaConPie({
    super.key,
    required this.children,
    required this.pie,
    this.espacio = 16,
  });

  final List<Widget> children;
  final Widget pie;

  /// Separación vertical entre los elementos.
  final double espacio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            // Deja sitio a las sombras, que se dibujan fuera de su widget.
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: espacio,
              children: children,
            ),
          ),
        ),
        SizedBox(height: espacio),
        pie,
      ],
    );
  }
}
