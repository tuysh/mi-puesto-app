import 'package:flutter/widgets.dart';

/// Cuadrito redondeado de color con un emoji en el centro.
class CuadroDeEmoji extends StatelessWidget {
  const CuadroDeEmoji({
    super.key,
    required this.emoji,
    required this.fondo,
    this.tamano = 42,
  });

  final String emoji;
  final Color fondo;

  /// Lado del cuadro.
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(tamano / 3),
      ),
      child: Text(
        emoji,
        style: TextStyle(fontSize: tamano * 0.52, height: 1.1),
      ),
    );
  }
}
