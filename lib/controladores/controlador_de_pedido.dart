import 'package:flutter/foundation.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';

/// El pedido que se está armando: qué productos lleva el cliente y cuántos.
class ControladorDePedido extends ChangeNotifier {
  /// Las líneas del pedido, guardadas por `id` de producto.
  /// Un `Map` de Dart conserva el orden en que se agregaron.
  final Map<String, LineaDePedido> _lineasPorProducto = {};

  List<LineaDePedido> get lineas => _lineasPorProducto.values.toList();

  bool get estaVacio => _lineasPorProducto.isEmpty;

  /// Total de piezas, sumando todos los productos.
  int get piezas {
    return lineas.fold(0, (suma, linea) => suma + linea.cantidad);
  }

  Dinero get total => sumarDinero(lineas.map((linea) => linea.subtotal));

  /// Cuántas piezas de [producto] hay en el pedido (0 si no está).
  int cantidadDe(Producto producto) {
    return _lineasPorProducto[producto.id]?.cantidad ?? 0;
  }

  /// Suma una pieza de [producto].
  void agregar(Producto producto) {
    _ponerCantidad(producto, cantidadDe(producto) + 1);
  }

  /// Resta una pieza de [producto]; al llegar a cero sale del pedido.
  void quitar(Producto producto) {
    _ponerCantidad(producto, cantidadDe(producto) - 1);
  }

  void vaciar() {
    _lineasPorProducto.clear();
    notifyListeners();
  }

  /// Cambia el pedido completo por [lineas].
  /// Sirve para recuperar el pedido de una venta registrada por error.
  void reemplazarLineas(List<LineaDePedido> lineas) {
    _lineasPorProducto.clear();
    for (final linea in lineas) {
      _lineasPorProducto[linea.producto.id] = linea;
    }
    notifyListeners();
  }

  void _ponerCantidad(Producto producto, int cantidad) {
    if (cantidad <= 0) {
      _lineasPorProducto.remove(producto.id);
    } else {
      _lineasPorProducto[producto.id] = LineaDePedido(
        producto: producto,
        cantidad: cantidad,
      );
    }
    notifyListeners();
  }
}
