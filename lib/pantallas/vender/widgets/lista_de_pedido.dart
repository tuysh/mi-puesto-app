import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/nucleo/widgets/linea_punteada.dart';
import 'package:mi_puesto/pantallas/vender/widgets/renglon_de_pedido.dart';

/// Todos los renglones del pedido que se está armando, uno debajo de otro
/// y con una raya entre ellos, como hoja de libreta.
///
/// Mide lo que miden sus renglones. Si son muchos, quien la usa la mete en
/// algo que se desplace.
class ListaDePedido extends StatelessWidget {
  const ListaDePedido({
    super.key,
    this.altoDeRenglon = 68,
    this.rayasPunteadas = true,
  });

  final double altoDeRenglon;

  /// Con `true` las rayas entre renglones son de guiones (teléfono); con
  /// `false`, continuas (tablet).
  final bool rayasPunteadas;

  @override
  Widget build(BuildContext context) {
    final dependencias = Dependencias.de(context);
    final pedido = dependencias.pedido;

    return ListenableBuilder(
      listenable: pedido,
      builder: (context, _) {
        if (pedido.estaVacio) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'Toca un producto para sumarlo',
              style: Tipografia.texto(15, color: Colores.tintaSuave),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final linea in pedido.lineas) ...[
              RenglonDePedido(
                alto: altoDeRenglon,
                imagen: ImagenDeProducto.de(
                  // El producto como está AHORA en el catálogo: si le
                  // cambiaron la foto, la copia del pedido trae una
                  // dirección que ya no existe.
                  dependencias.catalogo.buscarProducto(linea.producto.id) ??
                      linea.producto,
                  colores: dependencias.catalogo.coloresDe(
                    linea.producto.categoriaId,
                  ),
                  tamano: 40,
                ),
                nombre: linea.producto.nombre,
                detalle: _detalleDe(linea),
                cantidad: linea.cantidad,
                nombreParaLeer: linea.nombreCompleto,
                alQuitar: () => pedido.quitar(
                  linea.producto,
                  presentacion: linea.presentacion,
                ),
                alAgregar: () => pedido.agregar(
                  linea.producto,
                  presentacion: linea.presentacion,
                ),
              ),
              if (rayasPunteadas)
                const LineaPunteada()
              else
                const Divider(height: 2, thickness: 2, color: Colores.borde),
            ],
          ],
        );
      },
    );
  }

  /// "Grande · $25 c/u", o solo "$35 c/u" si el producto no tiene tamaños.
  String _detalleDe(LineaDePedido linea) {
    final precio = '${formatearDinero(linea.precioUnitario)} c/u';
    final tamano = linea.presentacion?.nombre;
    return tamano == null ? precio : '$tamano · $precio';
  }
}
