import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/controladores/controlador_de_catalogo.dart';
import 'package:mi_puesto/datos/modelos/resumen_del_dia.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_de_seccion.dart';
import 'package:mi_puesto/pantallas/hoy/widgets/renglon_de_mas_vendido.dart';

/// La tarjeta "Lo más vendido" de la pantalla "Hoy".
class SeccionDeMasVendidos extends StatelessWidget {
  const SeccionDeMasVendidos({super.key, required this.masVendidos});

  /// Ordenados del más vendido al menos vendido.
  final List<ProductoVendido> masVendidos;

  @override
  Widget build(BuildContext context) {
    final catalogo = Dependencias.de(context).catalogo;

    // El primero es el más vendido: su barra se dibuja completa y las
    // demás se comparan contra él.
    final piezasDelPrimero = masVendidos.isEmpty ? 1 : masVendidos.first.piezas;

    return TarjetaDeSeccion(
      titulo: 'Lo más vendido',
      children: [
        for (final vendido in masVendidos)
          RenglonDeMasVendido(
            imagen: _imagen(catalogo, vendido),
            // Si el producto sigue en el catálogo se usa su nombre corto,
            // que es el que cabe mejor en el renglón.
            nombre:
                catalogo.buscarProducto(vendido.productoId)?.nombreCorto ??
                vendido.nombre,
            piezas: vendido.piezas,
            fraccion: vendido.piezas / piezasDelPrimero,
          ),
      ],
    );
  }

  /// La imagen del producto como está hoy en el catálogo. Si el producto
  /// ya no existe, el emoji con el que se vendió sobre un fondo gris.
  Widget _imagen(ControladorDeCatalogo catalogo, ProductoVendido vendido) {
    final producto = catalogo.buscarProducto(vendido.productoId);
    if (producto == null) {
      return ImagenDeProducto(
        nombre: vendido.nombre,
        emoji: vendido.emoji,
        colores: const ParDeColores(
          fondo: Colores.superficieHundida,
          tinta: Colores.tinta,
        ),
      );
    }

    return ImagenDeProducto.de(
      producto,
      colores: catalogo.categoriaDe(producto).colores,
    );
  }
}
