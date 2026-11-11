import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/pantallas/vender/widgets/tesela_de_producto.dart';
import 'package:mi_puesto/pantallas/vender/widgets/tesela_de_producto_en_tablet.dart';

/// En teléfono: siempre dos columnas.
const _rejillaDeTelefono = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisExtent: TeselaDeProducto.alto,
  crossAxisSpacing: 10,
  mainAxisSpacing: 10,
);

/// En tablet: tantas columnas como quepan, con teselas de no más de 200 de
/// ancho (cuatro columnas en una tablet de 8.7").
const _rejillaDeTablet = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 200,
  mainAxisExtent: TeselaDeProductoEnTablet.alto,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
);

/// La cuadrícula de productos que se tocan para sumarlos al pedido.
class CuadriculaDeProductos extends StatelessWidget {
  const CuadriculaDeProductos({
    super.key,
    required this.productos,
    required this.alTocarProducto,
    required this.relleno,
    this.esDeTablet = false,
  });

  final List<Producto> productos;

  /// Se llama al tocar un producto que sí hay hoy. Quien lo recibe decide
  /// si suma una pieza o abre la hoja de tamaños.
  final ValueChanged<Producto> alTocarProducto;

  /// Espacio alrededor de la cuadrícula. En tablet debe dejar al menos 8
  /// arriba y a la derecha para que no se corte la insignia de cantidad.
  final EdgeInsets relleno;

  /// Con `true` se usan las teselas y las columnas de tablet.
  final bool esDeTablet;

  @override
  Widget build(BuildContext context) {
    final dependencias = Dependencias.de(context);

    // Se redibuja cuando cambia el pedido, para actualizar las cantidades.
    return ListenableBuilder(
      listenable: dependencias.pedido,
      builder: (context, _) {
        return GridView.builder(
          padding: relleno,
          gridDelegate: esDeTablet ? _rejillaDeTablet : _rejillaDeTelefono,
          itemCount: productos.length,
          itemBuilder: (context, posicion) {
            final producto = productos[posicion];
            final colores = dependencias.catalogo.coloresDe(
              producto.categoriaId,
            );
            // Un producto con tamaños suma las piezas de todos ellos.
            final cantidad = dependencias.pedido.piezasDe(producto);

            if (esDeTablet) {
              return TeselaDeProductoEnTablet(
                producto: producto,
                colores: colores,
                cantidad: cantidad,
                alTocar: () => alTocarProducto(producto),
              );
            }

            return TeselaDeProducto(
              producto: producto,
              colores: colores,
              cantidad: cantidad,
              alTocar: () => alTocarProducto(producto),
              alQuitar: () => dependencias.pedido.quitar(producto),
            );
          },
        );
      },
    );
  }
}
