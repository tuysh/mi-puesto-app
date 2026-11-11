import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/presentacion.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';

/// Un renglón del pedido: un producto, su tamaño (si tiene) y cuántas
/// piezas se llevan. Cada tamaño de un mismo producto es su propio renglón.
class LineaDePedido {
  const LineaDePedido({
    required this.producto,
    required this.cantidad,
    this.presentacion,
  });

  final Producto producto;

  /// El tamaño elegido; `null` si el producto se vende a un solo precio.
  final Presentacion? presentacion;

  final int cantidad;

  /// Lo que distingue a este renglón de los demás del pedido.
  String get llave => llaveDeLinea(producto, presentacion);

  Dinero get precioUnitario {
    return presentacion?.precio ?? producto.precio ?? Dinero.cero;
  }

  Dinero get subtotal => precioUnitario * cantidad;

  /// El nombre con su tamaño: "Horchata grande". Sin tamaño, solo el nombre.
  String get nombreCompleto {
    return unirNombreYTamano(producto.nombre, presentacion?.nombre ?? '');
  }
}

/// La llave de un renglón: el producto y, si tiene, su tamaño.
String llaveDeLinea(Producto producto, Presentacion? presentacion) {
  return '${producto.id}/${presentacion?.id ?? ''}';
}

/// "Horchata" y "Grande" → "Horchata grande".
String unirNombreYTamano(String nombre, String tamano) {
  if (tamano.isEmpty) return nombre;
  return '$nombre ${tamano.toLowerCase()}';
}
