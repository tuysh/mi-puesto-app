import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Línea horizontal de guiones, para separar los renglones del total.
class LineaPunteada extends StatelessWidget {
  const LineaPunteada({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 2,
      width: double.infinity,
      child: CustomPaint(painter: _PintorDeGuiones()),
    );
  }
}

class _PintorDeGuiones extends CustomPainter {
  const _PintorDeGuiones();

  static const _largoDelGuion = 6.0;
  static const _espacioEntreGuiones = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = Colores.borde
      ..strokeWidth = size.height;
    final y = size.height / 2;

    // Dibuja guion, deja un espacio, y repite hasta llegar al final.
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + _largoDelGuion, y), pincel);
      x += _largoDelGuion + _espacioEntreGuiones;
    }
  }

  @override
  bool shouldRepaint(_PintorDeGuiones oldDelegate) => false;
}
