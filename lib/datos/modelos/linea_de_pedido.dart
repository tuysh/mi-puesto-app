import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';

/// Un renglón del pedido: un producto y cuántas piezas se llevan.
class LineaDePedido {
  const LineaDePedido({required this.producto, required this.cantidad});

  final Producto producto;
  final int cantidad;

  Dinero get subtotal => producto.precio * cantidad;
}
