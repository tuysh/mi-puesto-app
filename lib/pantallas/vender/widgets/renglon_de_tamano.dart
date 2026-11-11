import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/pantallas/vender/widgets/control_de_cantidad.dart';

/// Un tamaño en la hoja "¿De qué tamaño?": su nombre, su precio y los
/// botones para decir cuántas piezas van.
class RenglonDeTamano extends StatelessWidget {
  const RenglonDeTamano({
    super.key,
    required this.nombre,
    required this.precio,
    required this.colorDelPrecio,
    required this.cantidad,
    required this.nombreParaLeer,
    required this.alQuitar,
    required this.alAgregar,
  });

  /// El nombre del tamaño: "Chica".
  final String nombre;

  /// El precio ya convertido a texto, por ejemplo `$15`.
  final String precio;

  final Color colorDelPrecio;
  final int cantidad;

  /// El producto con su tamaño, para los lectores de pantalla.
  final String nombreParaLeer;

  final VoidCallback alQuitar;
  final VoidCallback alAgregar;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.fromLTRB(16, 0, 14, 0),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  nombre,
                  style: Tipografia.texto(18, peso: 800, altura: 1.15),
                ),
                Cifra(precio, tamano: 17, color: colorDelPrecio),
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
