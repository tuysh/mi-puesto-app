import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/pantallas/vender/texto_de_precio.dart';
import 'package:mi_puesto/pantallas/vender/widgets/boton_de_quitar_pieza.dart';
import 'package:mi_puesto/pantallas/vender/widgets/marco_de_tesela.dart';
import 'package:mi_puesto/pantallas/vender/widgets/pie_de_tesela.dart';

/// El botón de un producto ("tesela") en teléfono. Arriba, su imagen
/// (foto, emoji o letras) junto al nombre y el precio; abajo, un renglón
/// que dice qué pasa al tocar o cuántas piezas van.
///
/// Hay tres casos:
/// - Un solo precio: tocarla suma una pieza. Con piezas en el pedido se
///   marca con un borde oscuro y aparece un "−" para quitar una.
/// - Con tamaños: tocarla abre la hoja para elegir cuál. No tiene "−":
///   las piezas se quitan en esa hoja o en el pedido.
/// - "Hoy no hay": se ve apagada y no responde.
///
/// En tablet se usa `TeselaDeProductoEnTablet`, que es más bajita.
class TeselaDeProducto extends StatelessWidget {
  const TeselaDeProducto({
    super.key,
    required this.producto,
    required this.colores,
    required this.cantidad,
    required this.alTocar,
    required this.alQuitar,
  });

  final Producto producto;

  /// Los colores de la categoría del producto.
  final ParDeColores colores;

  /// Cuántas piezas de este producto lleva el pedido, sumando sus tamaños.
  final int cantidad;

  /// Suma una pieza o, si el producto tiene tamaños, abre la hoja.
  final VoidCallback alTocar;

  /// Quita una pieza. Solo se usa en productos de un solo precio.
  final VoidCallback alQuitar;

  /// Alto fijo de la tesela; la cuadrícula lo usa para sus renglones.
  static const alto = 126.0;

  EstadoDeTesela get _estado {
    if (!producto.disponible) return EstadoDeTesela.noHay;
    if (producto.tieneTamanos) return EstadoDeTesela.paraElegirTamano;
    return EstadoDeTesela.paraAgregar;
  }

  String get _etiqueta {
    final nombre = producto.nombre;
    final llevas = cantidad > 0 ? ', llevas $cantidad' : '';

    return switch (_estado) {
      EstadoDeTesela.noHay => '$nombre, hoy no hay',
      EstadoDeTesela.paraElegirTamano => '$nombre, elegir tamaño$llevas',
      EstadoDeTesela.paraAgregar =>
        'Sumar $nombre, ${textoDePrecio(producto)}$llevas',
    };
  }

  @override
  Widget build(BuildContext context) {
    final estaEnElPedido = cantidad > 0;
    final hayHoy = producto.disponible;
    final llevaMenos = estaEnElPedido && !producto.tieneTamanos;

    return Opacity(
      opacity: hayHoy ? 1 : 0.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MarcoDeTesela(
            estaEnElPedido: estaEnElPedido,
            alTocar: hayHoy ? alTocar : null,
            etiqueta: _etiqueta,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Column(
                children: [
                  Expanded(child: _construirProducto()),
                  PieDeTesela(
                    estado: _estado,
                    cantidad: cantidad,
                    colores: colores,
                    dejarHuecoParaElMenos: llevaMenos,
                  ),
                ],
              ),
            ),
          ),
          // El "−" va encima del renglón de abajo, en el hueco que deja.
          if (llevaMenos)
            Positioned(
              left: 4,
              bottom: 4,
              child: BotonDeQuitarPieza(
                alTocar: alQuitar,
                etiqueta: 'Quitar un ${producto.nombre}',
              ),
            ),
        ],
      ),
    );
  }

  /// La imagen y, a su derecha, el nombre con el precio debajo.
  Widget _construirProducto() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        ImagenDeProducto.de(producto, colores: colores, tamano: 52, radio: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  producto.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Tipografia.texto(14, peso: 800, altura: 1.15),
                ),
                // FittedBox encoge "desde $15" si la tesela es angosta.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Cifra(
                    textoDePrecio(producto),
                    tamano: 18,
                    color: colores.tinta,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
