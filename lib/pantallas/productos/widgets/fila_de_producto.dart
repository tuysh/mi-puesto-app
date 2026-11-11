import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/nucleo/widgets/interruptor.dart';
import 'package:mi_puesto/nucleo/widgets/pastilla.dart';
import 'package:mi_puesto/pantallas/productos/widgets/columnas_de_tabla.dart';
import 'package:mi_puesto/pantallas/vender/texto_de_precio.dart';

/// Una fila de la tabla de productos (tablet). Al tocarla se elige el
/// producto para editarlo; el interruptor dice si hay hoy.
class FilaDeProducto extends StatelessWidget {
  const FilaDeProducto({
    super.key,
    required this.producto,
    required this.categoria,
    required this.estaElegida,
    required this.alTocar,
    required this.alCambiarSiHayHoy,
  });

  final Producto producto;

  /// `null` si el producto no tiene categoría.
  final Categoria? categoria;

  /// La fila elegida se pinta con fondo rosa.
  final bool estaElegida;

  final VoidCallback alTocar;

  /// Recibe `true` si se acaba de encender "Hay hoy".
  final ValueChanged<bool> alCambiarSiHayHoy;

  @override
  Widget build(BuildContext context) {
    final categoria = this.categoria;
    final cuantosTamanos = producto.presentaciones.length;

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
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                flex: ColumnasDeTabla.producto,
                child: _construirNombre(),
              ),
              Expanded(
                flex: ColumnasDeTabla.categoria,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: categoria == null
                      ? null
                      : Pastilla(
                          texto: categoria.nombre,
                          colores: categoria.colores,
                          alto: 30,
                        ),
                ),
              ),
              Expanded(
                flex: ColumnasDeTabla.precio,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 2,
                  children: [
                    Cifra(textoDePrecio(producto), tamano: 18),
                    if (producto.tieneTamanos)
                      Text(
                        '$cuantosTamanos tamaños',
                        style: Tipografia.texto(13, color: Colores.tintaSuave),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: ColumnasDeTabla.hayHoy,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Interruptor(
                    activo: producto.disponible,
                    alCambiar: alCambiarSiHayHoy,
                    etiqueta: 'Hay hoy: ${producto.nombre}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirNombre() {
    return Row(
      spacing: 12,
      children: [
        ImagenDeProducto.de(
          producto,
          colores: categoria?.colores ?? Colores.sinCategoria,
        ),
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
}
