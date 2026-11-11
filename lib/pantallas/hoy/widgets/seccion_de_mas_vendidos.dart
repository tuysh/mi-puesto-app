import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/nucleo/widgets/renglon_de_mas_vendido.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_de_seccion.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';

/// La tarjeta "Lo más vendido": un renglón por producto, con una barra que
/// lo compara con el primero. La usan "Hoy" y "Reportes".
class SeccionDeMasVendidos extends StatelessWidget {
  const SeccionDeMasVendidos({
    super.key,
    required this.productos,
    required this.orden,
    this.alLadoDelTitulo,
  });

  /// Ya ordenados, del más vendido al menos vendido.
  final List<ProductoVendido> productos;

  /// Con qué se comparan: por piezas o por dinero. Decide qué número se
  /// escribe y qué tan llena va cada barra.
  final OrdenDeProductos orden;

  /// Lo que va a la derecha del título: en "Reportes", el interruptor
  /// "Piezas · Dinero".
  final Widget? alLadoDelTitulo;

  /// El número con el que se compara un producto, según [orden].
  int _medidaDe(ProductoVendido producto) {
    return orden == OrdenDeProductos.cantidad
        ? producto.piezas
        : producto.vendido.centavos;
  }

  @override
  Widget build(BuildContext context) {
    final catalogo = Dependencias.de(context).catalogo;
    // El primero es el más vendido: su barra va llena.
    final mayor = productos.isEmpty ? 0 : _medidaDe(productos.first);

    return TarjetaDeSeccion(
      titulo: 'Lo más vendido',
      alLadoDelTitulo: alLadoDelTitulo,
      children: [
        if (productos.isEmpty) const TextoDeAyuda('Todavía no hay ventas.'),
        for (final producto in productos)
          RenglonDeMasVendido(
            imagen: ImagenDeProducto.deVendido(
              producto,
              colores: catalogo.coloresDe(producto.categoriaId),
              tamano: 40,
            ),
            nombre: producto.nombreCompleto,
            valor: orden == OrdenDeProductos.cantidad
                ? '${producto.piezas} pzs'
                : formatearDinero(producto.vendido),
            fraccion: mayor == 0 ? 0 : _medidaDe(producto) / mayor,
          ),
      ],
    );
  }
}
