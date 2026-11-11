import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/pantallas/vender/widgets/control_de_cantidad.dart';

/// Un renglón de pedido: la imagen del producto, su nombre, un detalle
/// ("Grande · $25 c/u") y los botones para quitar o agregar piezas.
///
/// No sabe de dónde salen los datos: lo usan el pedido que se está armando
/// y la pantalla de editar una venta ya hecha.
class RenglonDePedido extends StatelessWidget {
  const RenglonDePedido({
    super.key,
    required this.imagen,
    required this.nombre,
    required this.detalle,
    required this.cantidad,
    required this.nombreParaLeer,
    required this.alQuitar,
    required this.alAgregar,
    this.alto = 68,
  });

  /// El cuadrito con la foto, el emoji o las letras del producto. Puede
  /// ser `null` si no se sabe cómo se ve (el producto ya no existe).
  final Widget? imagen;

  final String nombre;

  /// El tamaño (si tiene) y el precio por pieza: "Grande · $25 c/u".
  final String detalle;

  final int cantidad;

  /// El nombre con su tamaño, para los lectores de pantalla.
  final String nombreParaLeer;

  final VoidCallback alQuitar;
  final VoidCallback alAgregar;

  final double alto;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: alto,
      child: Row(
        spacing: 10,
        children: [
          ?imagen,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Tipografia.texto(16, peso: 800, altura: 1.15),
                ),
                Text(
                  detalle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Tipografia.texto(
                    14,
                    color: Colores.tintaSuave,
                    altura: 1.15,
                  ),
                ),
              ],
            ),
          ),
          ControlDeCantidad(
            cantidad: cantidad,
            nombre: nombreParaLeer,
            alQuitar: alQuitar,
            alAgregar: alAgregar,
          ),
        ],
      ),
    );
  }
}
