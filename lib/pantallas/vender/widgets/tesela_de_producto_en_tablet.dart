import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/pantallas/vender/texto_de_precio.dart';
import 'package:mi_puesto/pantallas/vender/widgets/insignia_de_cantidad.dart';
import 'package:mi_puesto/pantallas/vender/widgets/marco_de_tesela.dart';

/// El botón de un producto ("tesela") en tablet: su imagen (foto, emoji o
/// letras) a la izquierda y, a la derecha, el nombre y el precio.
///
/// Tocarla suma una pieza o, si el producto tiene tamaños, abre la hoja
/// para elegir cuál. Si hoy no hay, se ve apagada, dice "Hoy no hay" en
/// lugar del precio y no responde.
///
/// Cuando el producto ya está en el pedido se marca con un borde oscuro y
/// una insignia con la cantidad arriba a la derecha. No tiene "−": en
/// tablet las piezas se quitan en el pedido, que siempre está a la vista.
class TeselaDeProductoEnTablet extends StatelessWidget {
  const TeselaDeProductoEnTablet({
    super.key,
    required this.producto,
    required this.colores,
    required this.cantidad,
    required this.alTocar,
  });

  final Producto producto;

  /// Los colores de la categoría del producto.
  final ParDeColores colores;

  /// Cuántas piezas de este producto lleva el pedido, sumando sus tamaños.
  final int cantidad;

  /// Suma una pieza o abre la hoja de tamaños.
  final VoidCallback alTocar;

  /// Alto fijo de la tesela; la cuadrícula lo usa para sus renglones.
  static const alto = 88.0;

  @override
  Widget build(BuildContext context) {
    final estaEnElPedido = cantidad > 0;
    final hayHoy = producto.disponible;
    final precio = hayHoy ? textoDePrecio(producto) : 'Hoy no hay';

    return Opacity(
      opacity: hayHoy ? 1 : 0.5,
      child: Stack(
        // Permite que la insignia sobresalga de la esquina de la tesela.
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          MarcoDeTesela(
            estaEnElPedido: estaEnElPedido,
            alTocar: hayHoy ? alTocar : null,
            etiqueta: estaEnElPedido
                ? '${producto.nombre}, $precio, llevas $cantidad'
                : '${producto.nombre}, $precio',
            child: Padding(
              // Márgenes justos (10 y no 12) para que un nombre de una sola
              // palabra larga, como "Tostilocos", quepa sin partirse.
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                spacing: 10,
                children: [
                  ImagenDeProducto.de(
                    producto,
                    colores: colores,
                    tamano: 64,
                    radio: 16,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        Text(
                          producto.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Tipografia.texto(16, peso: 800, altura: 1.15),
                        ),
                        // FittedBox encoge "desde $15" si no cabe.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Cifra(
                            precio,
                            tamano: 19,
                            color: hayHoy ? colores.tinta : Colores.tintaSuave,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (estaEnElPedido)
            Positioned(
              top: -7,
              right: -7,
              child: InsigniaDeCantidad(cantidad: cantidad),
            ),
        ],
      ),
    );
  }
}
