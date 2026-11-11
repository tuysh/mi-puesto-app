import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/pantallas/vender/widgets/boton_de_cantidad.dart';

/// Los botones "−" y "+" con la cantidad en medio. Sirve para cambiar
/// cuántas piezas van de un producto: en el pedido, al elegir tamaño y al
/// editar una venta.
class ControlDeCantidad extends StatelessWidget {
  const ControlDeCantidad({
    super.key,
    required this.cantidad,
    required this.nombre,
    required this.alQuitar,
    required this.alAgregar,
  });

  final int cantidad;

  /// De qué son las piezas, para los lectores de pantalla: "Horchata
  /// grande" → "Quitar un Horchata grande".
  final String nombre;

  final VoidCallback alQuitar;
  final VoidCallback alAgregar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        BotonDeCantidad(
          icono: Icons.remove_rounded,
          etiqueta: 'Quitar un $nombre',
          alTocar: alQuitar,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 20),
          child: Center(widthFactor: 1, child: Cifra('$cantidad', tamano: 20)),
        ),
        BotonDeCantidad(
          icono: Icons.add_rounded,
          etiqueta: 'Agregar un $nombre',
          esDeSumar: true,
          alTocar: alAgregar,
        ),
      ],
    );
  }
}
