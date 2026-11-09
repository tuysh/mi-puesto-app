import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/pantallas/vender/widgets/tesela_de_producto.dart';

/// En teléfono: siempre tres columnas.
const rejillaDeTelefono = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,
  mainAxisExtent: TeselaDeProducto.alto,
  crossAxisSpacing: 10,
  mainAxisSpacing: 10,
);

/// En tablet: tantas columnas como quepan, con teselas de no más de 170 de
/// ancho (cinco columnas en una tablet de 8.7").
const rejillaDeTablet = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 170,
  mainAxisExtent: TeselaDeProducto.alto,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
);

/// La cuadrícula de productos que se tocan para sumarlos al pedido.
class CuadriculaDeProductos extends StatelessWidget {
  const CuadriculaDeProductos({
    super.key,
    required this.productos,
    required this.rejilla,
    required this.alTocarProducto,
    required this.relleno,
  });

  final List<Producto> productos;

  /// Cómo se reparten las columnas: [rejillaDeTelefono] o [rejillaDeTablet].
  final SliverGridDelegate rejilla;

  final ValueChanged<Producto> alTocarProducto;

  /// Espacio alrededor de la cuadrícula. Debe dejar al menos 8 arriba y a la
  /// derecha para que no se corte la insignia de cantidad.
  final EdgeInsets relleno;

  @override
  Widget build(BuildContext context) {
    final dependencias = Dependencias.de(context);

    // Se redibuja cuando cambia el pedido, para actualizar las cantidades.
    return ListenableBuilder(
      listenable: dependencias.pedido,
      builder: (context, _) {
        return GridView.builder(
          padding: relleno,
          gridDelegate: rejilla,
          itemCount: productos.length,
          itemBuilder: (context, posicion) {
            final producto = productos[posicion];

            return TeselaDeProducto(
              producto: producto,
              colores: dependencias.catalogo.categoriaDe(producto).colores,
              cantidad: dependencias.pedido.cantidadDe(producto),
              alTocar: () => alTocarProducto(producto),
              alQuitar: () => dependencias.pedido.quitar(producto),
            );
          },
        );
      },
    );
  }
}
