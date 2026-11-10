import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/pantallas/vender/widgets/boton_de_cantidad.dart';

/// Un renglón del pedido: el producto, su subtotal y los botones para
/// quitar o agregar piezas. Lleva una raya debajo, como hoja de libreta.
class RenglonDePedido extends StatelessWidget {
  const RenglonDePedido({
    super.key,
    required this.linea,
    required this.colores,
    required this.alQuitar,
    required this.alAgregar,
  });

  final LineaDePedido linea;

  /// Los colores de la categoría del producto.
  final ParDeColores colores;
  final VoidCallback alQuitar;
  final VoidCallback alAgregar;

  @override
  Widget build(BuildContext context) {
    final nombre = linea.producto.nombreCorto;

    return Container(
      height: 57,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colores.borde, width: 2)),
      ),
      child: Row(
        spacing: 10,
        children: [
          ImagenDeProducto.de(linea.producto, colores: colores, tamano: 38),
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
                Cifra(
                  formatearDinero(linea.subtotal),
                  tamano: 15,
                  peso: 600,
                  color: Colores.tintaSuave,
                ),
              ],
            ),
          ),
          BotonDeCantidad(
            icono: Icons.remove_rounded,
            etiqueta: 'Quitar un $nombre',
            alTocar: alQuitar,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 20),
            child: Center(
              widthFactor: 1,
              child: Cifra('${linea.cantidad}', tamano: 20),
            ),
          ),
          BotonDeCantidad(
            icono: Icons.add_rounded,
            etiqueta: 'Agregar un $nombre',
            esDeSumar: true,
            alTocar: alAgregar,
          ),
        ],
      ),
    );
  }
}
