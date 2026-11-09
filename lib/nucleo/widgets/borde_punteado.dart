import 'package:flutter/widgets.dart';

/// Dibuja un borde de guiones con esquinas redondeadas alrededor de [child].
class BordePunteado extends StatelessWidget {
  const BordePunteado({
    super.key,
    required this.child,
    required this.color,
    required this.radio,
  });

  final Widget child;
  final Color color;
  final double radio;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PintorDeBordePunteado(color: color, radio: radio),
      child: child,
    );
  }
}

class _PintorDeBordePunteado extends CustomPainter {
  const _PintorDeBordePunteado({required this.color, required this.radio});

  final Color color;
  final double radio;

  static const _grosor = 2.0;
  static const _largoDelGuion = 7.0;
  static const _espacioEntreGuiones = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = color
      ..strokeWidth = _grosor
      ..style = PaintingStyle.stroke;

    // El contorno completo, como un solo trazo continuo.
    final contorno = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(_grosor / 2),
          Radius.circular(radio),
        ),
      );

    // Recorre el contorno y dibuja solo los tramos que son guion.
    for (final tramo in contorno.computeMetrics()) {
      var inicio = 0.0;
      while (inicio < tramo.length) {
        final guion = tramo.extractPath(inicio, inicio + _largoDelGuion);
        canvas.drawPath(guion, pincel);
        inicio += _largoDelGuion + _espacioEntreGuiones;
      }
    }
  }

  @override
  bool shouldRepaint(_PintorDeBordePunteado oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radio != radio;
  }
}
