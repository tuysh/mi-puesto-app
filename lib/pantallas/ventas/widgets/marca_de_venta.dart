import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/pastilla.dart';

/// La pastilla chica que marca una venta en la lista: "Cancelada" (ámbar)
/// o "Editada" (gris). Una venta sin cambios no lleva marca.
class MarcaDeVenta extends StatelessWidget {
  const MarcaDeVenta({super.key, required this.venta});

  final Venta venta;

  /// `true` si [venta] lleva marca. Sirve para no dejar un hueco cuando
  /// no la lleva.
  static bool haceFaltaPara(Venta venta) {
    return venta.estaCancelada || venta.fueEditada;
  }

  @override
  Widget build(BuildContext context) {
    if (venta.estaCancelada) {
      return const Pastilla.chica(texto: 'Cancelada', colores: Colores.alerta);
    }
    return const Pastilla.chica(
      texto: 'Editada',
      colores: Colores.sinCategoria,
    );
  }
}
