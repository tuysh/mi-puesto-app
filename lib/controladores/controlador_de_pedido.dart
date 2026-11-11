import 'package:flutter/foundation.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/presentacion.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';

/// El pedido que se está armando: qué productos lleva el cliente y cuántos.
///
/// Un producto con tamaños ocupa un renglón por cada tamaño. Por eso casi
/// todos los métodos reciben el producto y, si tiene, su `presentacion`.
class ControladorDePedido extends ChangeNotifier {
  /// Los renglones del pedido, guardados por su llave (producto y tamaño).
  /// Un `Map` de Dart conserva el orden en que se agregaron.
  final Map<String, LineaDePedido> _lineasPorLlave = {};

  List<LineaDePedido> get lineas => _lineasPorLlave.values.toList();

  bool get estaVacio => _lineasPorLlave.isEmpty;

  /// Total de piezas, sumando todos los renglones.
  int get piezas {
    return lineas.fold(0, (suma, linea) => suma + linea.cantidad);
  }

  Dinero get total => sumarDinero(lineas.map((linea) => linea.subtotal));

  /// Cuántas piezas hay de [producto] en ese tamaño (0 si no está).
  int cantidadDe(Producto producto, {Presentacion? presentacion}) {
    final llave = llaveDeLinea(producto, presentacion);
    return _lineasPorLlave[llave]?.cantidad ?? 0;
  }

  /// Cuántas piezas hay de [producto], sumando todos sus tamaños.
  int piezasDe(Producto producto) {
    var suma = 0;
    for (final linea in lineas) {
      if (linea.producto.id == producto.id) suma += linea.cantidad;
    }
    return suma;
  }

  /// Suma una pieza de [producto].
  void agregar(Producto producto, {Presentacion? presentacion}) {
    final cantidad = cantidadDe(producto, presentacion: presentacion);
    ponerCantidad(producto, cantidad + 1, presentacion: presentacion);
  }

  /// Resta una pieza de [producto]; al llegar a cero sale del pedido.
  void quitar(Producto producto, {Presentacion? presentacion}) {
    final cantidad = cantidadDe(producto, presentacion: presentacion);
    ponerCantidad(producto, cantidad - 1, presentacion: presentacion);
  }

  /// Deja [producto] con exactamente [cantidad] piezas. Con cero o menos,
  /// el renglón sale del pedido.
  void ponerCantidad(
    Producto producto,
    int cantidad, {
    Presentacion? presentacion,
  }) {
    final llave = llaveDeLinea(producto, presentacion);
    if (cantidad <= 0) {
      _lineasPorLlave.remove(llave);
    } else {
      _lineasPorLlave[llave] = LineaDePedido(
        producto: producto,
        presentacion: presentacion,
        cantidad: cantidad,
      );
    }
    notifyListeners();
  }

  void vaciar() {
    _lineasPorLlave.clear();
    notifyListeners();
  }
}
