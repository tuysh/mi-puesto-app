import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/nucleo/widgets/interruptor.dart';
import 'package:mi_puesto/pantallas/vender/texto_de_precio.dart';

/// Un producto en la lista de "Productos" (teléfono): su imagen, su nombre
/// y, debajo, el precio, la categoría y cuántos tamaños tiene. A la
/// derecha, el interruptor "Hay hoy". Al tocar lo demás se edita.
class FilaDeProductoEnLista extends StatelessWidget {
  const FilaDeProductoEnLista({
    super.key,
    required this.producto,
    required this.categoria,
    required this.alTocar,
    required this.alCambiarSiHayHoy,
  });

  final Producto producto;

  /// `null` si el producto no tiene categoría.
  final Categoria? categoria;

  final VoidCallback alTocar;

  /// Recibe `true` si se acaba de encender "Hay hoy".
  final ValueChanged<bool> alCambiarSiHayHoy;

  /// " · Bebidas · 2 tamaños": lo que va después del precio.
  String get _detalle {
    final cuantosTamanos = producto.presentaciones.length;
    return [
      '',
      ?categoria?.nombre,
      if (producto.tieneTamanos) '$cuantosTamanos tamaños',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final colores = categoria?.colores ?? Colores.sinCategoria;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: alTocar,
            child: Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
              child: Row(
                spacing: 12,
                children: [
                  ImagenDeProducto.de(producto, colores: colores, tamano: 44),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          producto.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Tipografia.texto(16, peso: 800, altura: 1.15),
                        ),
                        // El precio va en tinta y como cifra; lo demás,
                        // en gris.
                        Text.rich(
                          TextSpan(
                            text: textoDePrecio(producto),
                            style: Tipografia.cifra(14),
                            children: [
                              TextSpan(
                                text: _detalle,
                                style: Tipografia.texto(
                                  14,
                                  color: Colores.tintaSuave,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Interruptor(
            activo: producto.disponible,
            etiqueta: 'Hay hoy: ${producto.nombre}',
            alCambiar: alCambiarSiHayHoy,
          ),
        ),
      ],
    );
  }
}
