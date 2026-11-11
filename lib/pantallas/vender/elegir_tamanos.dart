import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/hoja_inferior.dart';
import 'package:mi_puesto/pantallas/vender/widgets/selector_de_tamanos.dart';

/// Abre "¿De qué tamaño?" para un producto que tiene varios tamaños. Al
/// tocar "Agregar", el pedido queda con las cantidades elegidas de cada
/// tamaño; al cancelar, el pedido no cambia.
Future<void> elegirTamanos(
  BuildContext context, {
  required Producto producto,
  required ParDeColores colores,
}) {
  return mostrarHoja<void>(
    context,
    contenido: SelectorDeTamanos(producto: producto, colores: colores),
  );
}
