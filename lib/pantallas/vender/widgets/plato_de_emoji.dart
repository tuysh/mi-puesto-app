import 'package:flutter/widgets.dart';

/// Círculo blanco translúcido con un emoji en el centro.
///
/// Todos los emojis se dibujan sobre un plato del mismo tamaño para que las
/// teselas se vean parejas, aunque cada emoji tenga una forma distinta.
class PlatoDeEmoji extends StatelessWidget {
  const PlatoDeEmoji({super.key, required this.emoji});

  final String emoji;

  static const _tamano = 48.0;

  /// Blanco al 72 %: deja ver un poco el color de la tesela.
  static const _blancoTranslucido = Color(0xB8FFFFFF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _tamano,
      height: _tamano,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _blancoTranslucido,
        shape: BoxShape.circle,
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 27, height: 1)),
    );
  }
}
