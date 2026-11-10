import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/nucleo/widgets/visual_de_producto.dart';
import 'package:mi_puesto/pantallas/vender/widgets/boton_de_quitar_pieza.dart';
import 'package:mi_puesto/pantallas/vender/widgets/insignia_de_cantidad.dart';

/// El botón de un producto ("tesela"): su imagen (foto, emoji o letras),
/// nombre corto y precio.
/// Tocarla suma una pieza al pedido.
///
/// Cuando el producto ya está en el pedido se marca con un borde oscuro,
/// una insignia con la cantidad arriba a la derecha y un "−" abajo a la
/// izquierda para quitar una pieza.
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

  /// Cuántas piezas de este producto lleva el pedido.
  final int cantidad;

  /// Suma una pieza.
  final VoidCallback alTocar;

  /// Quita una pieza.
  final VoidCallback alQuitar;

  /// Alto fijo de la tesela; las cuadrículas lo usan para sus renglones.
  static const alto = 136.0;

  /// Alto del renglón del precio. Es el mismo que la zona de toque del "−",
  /// que se dibuja a su izquierda.
  static const _altoDelPrecio = 44.0;

  /// Alto de la franja de arriba, donde va la foto, el emoji o las letras.
  static const _altoDeLaImagen = 62.0;

  @override
  Widget build(BuildContext context) {
    final estaEnElPedido = cantidad > 0;
    final precio = formatearDinero(producto.precio);

    return Stack(
      // Permite que la insignia sobresalga de la esquina de la tesela.
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        CajaTocable(
          alTocar: alTocar,
          etiqueta: estaEnElPedido
              ? '${producto.nombre}, $precio, llevas $cantidad'
              : '${producto.nombre}, $precio',
          radio: Radios.tarjeta,
          decoracion: BoxDecoration(
            color: colores.fondo,
            boxShadow: estaEnElPedido ? null : Sombras.dura(alto: 3),
          ),
          child: Column(
            children: [
              // La foto llega hasta la orilla, así que se recorta con las
              // esquinas redondeadas de la tesela.
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Radios.tarjeta),
                ),
                child: SizedBox(
                  height: _altoDeLaImagen,
                  width: double.infinity,
                  child: VisualDeProducto(
                    nombre: producto.nombreCorto,
                    tinta: colores.tinta,
                    tamanoDeEmoji: 34,
                    tamanoDeLetras: 28,
                    emoji: producto.emoji,
                    letras: producto.letras,
                    fotoUrl: producto.fotoUrl,
                  ),
                ),
              ),
              // El nombre ocupa el espacio que sobra y puede usar dos
              // renglones.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 2, 6, 0),
                  child: Center(
                    child: Text(
                      producto.nombreCorto,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Tipografia.texto(14, peso: 800, altura: 1.15),
                    ),
                  ),
                ),
              ),
              Container(
                height: _altoDelPrecio,
                alignment: Alignment.center,
                // Con el "−" a la izquierda, el precio se recorre para
                // quedar centrado en el espacio libre.
                padding: EdgeInsets.only(left: estaEnElPedido ? 42 : 0),
                child: Cifra(precio, tamano: 17, color: colores.tinta),
              ),
            ],
          ),
        ),
        // El borde oscuro va ENCIMA de todo, para que la foto no lo tape.
        // IgnorePointer deja pasar el toque a la tesela.
        if (estaEnElPedido)
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radios.tarjeta),
                border: Border.all(color: Colores.tinta, width: 3),
              ),
            ),
          ),
        if (estaEnElPedido)
          Positioned(
            top: -7,
            right: -7,
            child: InsigniaDeCantidad(cantidad: cantidad),
          ),
        if (estaEnElPedido)
          Positioned(
            left: 3,
            bottom: 2,
            child: BotonDeQuitarPieza(
              alTocar: alQuitar,
              etiqueta: 'Quitar un ${producto.nombre}',
            ),
          ),
      ],
    );
  }
}
