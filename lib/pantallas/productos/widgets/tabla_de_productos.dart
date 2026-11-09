import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/pantallas/productos/widgets/encabezado_de_tabla.dart';
import 'package:mi_puesto/pantallas/productos/widgets/fila_de_producto.dart';

/// La tabla con todos los productos, incluidos los ocultos.
class TablaDeProductos extends StatelessWidget {
  const TablaDeProductos({
    super.key,
    required this.productos,
    required this.alElegir,
    required this.alCambiarVisibilidad,
    this.idElegido,
    this.esCompacta = false,
  });

  final List<Producto> productos;
  final ValueChanged<Producto> alElegir;

  /// Recibe el producto y `true` (ponerlo a la venta) o `false` (ocultarlo).
  final void Function(Producto producto, bool aLaVenta) alCambiarVisibilidad;

  /// `id` del producto cuya fila se resalta; `null` para no resaltar nada.
  final String? idElegido;

  /// La tabla compacta (teléfono) solo muestra Producto, Precio y
  /// A la venta.
  final bool esCompacta;

  @override
  Widget build(BuildContext context) {
    final catalogo = Dependencias.de(context).catalogo;

    return Container(
      // Recorta las filas para que respeten las esquinas redondeadas.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colores.superficie,
        borderRadius: BorderRadius.circular(Radios.tarjeta),
        border: Border.all(color: Colores.borde, width: 2),
      ),
      child: Column(
        children: [
          EncabezadoDeTabla(esCompacta: esCompacta),
          Expanded(
            child: ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, posicion) {
                final producto = productos[posicion];

                return FilaDeProducto(
                  producto: producto,
                  categoria: catalogo.categoriaDe(producto),
                  estaElegida: producto.id == idElegido,
                  esCompacta: esCompacta,
                  alTocar: () => alElegir(producto),
                  alCambiarVisibilidad: (aLaVenta) {
                    alCambiarVisibilidad(producto, aLaVenta);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
