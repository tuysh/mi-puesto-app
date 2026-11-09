import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/pantallas/vender/widgets/insignia_de_cantidad.dart';

/// El botón de un producto ("tesela"): emoji, nombre corto y precio.
///
/// Cuando el producto ya está en el pedido se marca con un borde oscuro y
/// una insignia con la cantidad en la esquina.
class TeselaDeProducto extends StatelessWidget {
  const TeselaDeProducto({
    super.key,
    required this.producto,
    required this.colores,
    required this.cantidad,
    required this.alTocar,
  });

  final Producto producto;

  /// Los colores de la categoría del producto.
  final ParDeColores colores;

  /// Cuántas piezas de este producto lleva el pedido.
  final int cantidad;

  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final estaEnElPedido = cantidad > 0;
    final precio = formatearDinero(producto.precio);

    return Stack(
      // Permite que la insignia sobresalga de la esquina de la tesela.
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        CajaTocable(
          alTocar: alTocar,
          etiqueta: estaEnElPedido
              ? '${producto.nombre}, $precio, llevas $cantidad'
              : '${producto.nombre}, $precio',
          radio: Radios.tarjeta,
          decoracion: BoxDecoration(
            color: colores.fondo,
            border: estaEnElPedido
                ? Border.all(color: Colores.tinta, width: 3)
                : null,
            boxShadow: estaEnElPedido ? null : Sombras.dura(alto: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: [
                Text(
                  producto.emoji,
                  style: const TextStyle(fontSize: 32, height: 1.1),
                ),
                Text(
                  producto.nombreCorto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Tipografia.texto(14, peso: 800, altura: 1.15),
                ),
                Cifra(precio, tamano: 17, color: colores.tinta),
              ],
            ),
          ),
        ),
        if (estaEnElPedido)
          Positioned(
            top: -7,
            right: -7,
            child: InsigniaDeCantidad(cantidad: cantidad),
          ),
      ],
    );
  }
}
