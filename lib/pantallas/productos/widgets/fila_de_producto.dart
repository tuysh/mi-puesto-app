import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/nucleo/widgets/interruptor.dart';
import 'package:mi_puesto/nucleo/widgets/pastilla.dart';
import 'package:mi_puesto/pantallas/productos/widgets/columnas_de_tabla.dart';

/// Una fila de la tabla de productos. Al tocarla se elige el producto para
/// editarlo; el interruptor lo pone a la venta o lo oculta.
class FilaDeProducto extends StatelessWidget {
  const FilaDeProducto({
    super.key,
    required this.producto,
    required this.categoria,
    required this.estaElegida,
    required this.esCompacta,
    required this.alTocar,
    required this.alCambiarVisibilidad,
  });

  final Producto producto;
  final Categoria categoria;

  /// La fila elegida se pinta con fondo rosa.
  final bool estaElegida;

  /// La fila compacta (teléfono) no muestra Categoría ni Ganas.
  final bool esCompacta;

  final VoidCallback alTocar;

  /// Recibe `true` para poner el producto a la venta y `false` para ocultarlo.
  final ValueChanged<bool> alCambiarVisibilidad;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: estaElegida ? Colores.acentoSuave : Colores.superficie,
      child: InkWell(
        onTap: alTocar,
        child: Container(
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colores.superficieHundida),
            ),
          ),
          // Los productos ocultos se ven deslavados.
          child: Opacity(
            opacity: producto.aLaVenta ? 1 : 0.6,
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  flex: ColumnasDeTabla.producto,
                  child: _construirNombre(),
                ),
                if (!esCompacta)
                  Expanded(
                    flex: ColumnasDeTabla.categoria,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Pastilla(
                        texto: categoria.nombre,
                        colores: categoria.colores,
                        alto: 30,
                      ),
                    ),
                  ),
                Expanded(
                  flex: ColumnasDeTabla.precio,
                  child: _construirMonto(producto.precio, Colores.tinta),
                ),
                if (!esCompacta)
                  Expanded(
                    flex: ColumnasDeTabla.ganancia,
                    child: _construirMonto(
                      producto.ganancia,
                      Colores.exito.tinta,
                    ),
                  ),
                Expanded(
                  flex: ColumnasDeTabla.aLaVenta,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Interruptor(
                      activo: producto.aLaVenta,
                      alCambiar: alCambiarVisibilidad,
                      etiqueta: producto.aLaVenta ? 'A la venta' : 'Oculto',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirNombre() {
    return Row(
      spacing: 12,
      children: [
        ImagenDeProducto.de(producto, colores: categoria.colores),
        Expanded(
          child: Text(
            producto.nombre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Tipografia.texto(16, peso: 800, altura: 1.15),
          ),
        ),
      ],
    );
  }

  Widget _construirMonto(Dinero monto, Color color) {
    return Align(
      alignment: Alignment.centerRight,
      child: Cifra(formatearDinero(monto), tamano: 18, color: color),
    );
  }
}
