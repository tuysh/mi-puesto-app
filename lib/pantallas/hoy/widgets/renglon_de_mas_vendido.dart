import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/pantallas/hoy/widgets/barra_de_proporcion.dart';

/// Un producto de "Lo más vendido": su imagen, nombre, piezas vendidas y una
/// barra que lo compara con el producto más vendido.
class RenglonDeMasVendido extends StatelessWidget {
  const RenglonDeMasVendido({
    super.key,
    required this.imagen,
    required this.nombre,
    required this.piezas,
    required this.fraccion,
  });

  /// El cuadrito con la foto, el emoji o las letras del producto.
  final Widget imagen;

  final String nombre;
  final int piezas;

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
                children: [
                  Expanded(
                    child: Text(nombre, style: Tipografia.texto(15, peso: 800)),
                  ),
                  Cifra('$piezas pzs', tamano: 15),
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
