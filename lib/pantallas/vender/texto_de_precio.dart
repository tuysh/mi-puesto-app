import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';

/// El precio de [producto] como se escribe en sus botones y listas: `$45`
/// o, si tiene tamaños, `desde $15` (el del más barato).
String textoDePrecio(Producto producto) {
  final precio = formatearDinero(producto.precioDesde);
  return producto.tieneTamanos ? 'desde $precio' : precio;
}
