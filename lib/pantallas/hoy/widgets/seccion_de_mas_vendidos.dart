import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/resumen_del_dia.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_de_seccion.dart';
import 'package:mi_puesto/pantallas/hoy/widgets/renglon_de_mas_vendido.dart';

/// La tarjeta "Lo más vendido" de la pantalla "Hoy".
class SeccionDeMasVendidos extends StatelessWidget {
  const SeccionDeMasVendidos({super.key, required this.masVendidos});

  /// Ordenados del más vendido al menos vendido.
  final List<ProductoVendido> masVendidos;

  @override
  Widget build(BuildContext context) {
    final catalogo = Dependencias.de(context).catalogo;

    // El primero es el más vendido: su barra se dibuja completa y las
    // demás se comparan contra él.
    final piezasDelPrimero = masVendidos.isEmpty ? 1 : masVendidos.first.piezas;

    return TarjetaDeSeccion(
      titulo: 'Lo más vendido',
      children: [
        for (final vendido in masVendidos)
          RenglonDeMasVendido(
            emoji: vendido.producto.emoji,
            fondoDelEmoji: catalogo.categoriaDe(vendido.producto).colores.fondo,
            nombre: vendido.producto.nombreCorto,
            piezas: vendido.piezas,
            fraccion: vendido.piezas / piezasDelPrimero,
          ),
      ],
    );
  }
}
