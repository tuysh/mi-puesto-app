import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// La tarjeta blanca de una tesela de producto, que responde al toque.
///
/// Mientras el producto no está en el pedido lleva un borde claro. Cuando
/// ya está, el borde se vuelve oscuro y grueso y la tarjeta gana una sombra
/// dura, para que se distinga de un vistazo.
class MarcoDeTesela extends StatelessWidget {
  const MarcoDeTesela({
    super.key,
    required this.estaEnElPedido,
    required this.alTocar,
    required this.etiqueta,
    required this.child,
  });

  final bool estaEnElPedido;

  /// Si es `null`, la tesela no responde (hoy no hay ese producto).
  final VoidCallback? alTocar;

  /// Texto para lectores de pantalla, por ejemplo "Sumar Flan, $35".
  final String etiqueta;

  final Widget child;

  static const _radio = 20.0;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      etiqueta: etiqueta,
      radio: _radio,
      decoracion: BoxDecoration(
        color: Colores.superficie,
        border: Border.all(
          color: estaEnElPedido ? Colores.tinta : Colores.borde,
          width: estaEnElPedido ? 3 : 2,
        ),
        boxShadow: estaEnElPedido ? Sombras.dura(color: Colores.tinta) : null,
      ),
      child: child,
    );
  }
}
