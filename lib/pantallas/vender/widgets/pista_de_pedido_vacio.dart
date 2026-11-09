import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Texto de ayuda que solo se ve mientras el pedido está vacío.
class PistaDePedidoVacio extends StatelessWidget {
  const PistaDePedidoVacio({super.key});

  @override
  Widget build(BuildContext context) {
    final pedido = Dependencias.de(context).pedido;

    return ListenableBuilder(
      listenable: pedido,
      builder: (context, _) {
        if (!pedido.estaVacio) return const SizedBox.shrink();

        return Text(
          'Toca un producto para sumarlo',
          style: Tipografia.texto(15, color: Colores.tintaSuave),
        );
      },
    );
  }
}
