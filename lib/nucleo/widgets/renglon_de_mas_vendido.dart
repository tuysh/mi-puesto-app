import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/barra_de_proporcion.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';

/// Un producto de "Lo más vendido": su imagen, su nombre, cuánto se vendió
/// y una barra que lo compara con el producto más vendido.
class RenglonDeMasVendido extends StatelessWidget {
  const RenglonDeMasVendido({
    super.key,
    required this.imagen,
    required this.nombre,
    required this.valor,
    required this.fraccion,
  });

  /// El cuadrito con la foto, el emoji o las letras del producto.
  final Widget imagen;

  final String nombre;

  /// Lo vendido, ya como texto: `9 pzs` o `$1,710`.
  final String valor;

  /// Qué tan llena va la barra: 1 para el producto más vendido.
  final double fraccion;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        imagen,
        Expanded(
          child: Column(
            spacing: 5,
            children: [
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Tipografia.texto(15, peso: 800),
                    ),
                  ),
                  Cifra(valor, tamano: 15),
                ],
              ),
              BarraDeProporcion(fraccion: fraccion),
            ],
          ),
        ),
      ],
    );
  }
}
