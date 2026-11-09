import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';

/// Encabezado de "Productos": el título, cuántos productos están a la
/// venta y los botones "Categorías" y "Nuevo producto".
class EncabezadoDeProductos extends StatelessWidget {
  const EncabezadoDeProductos({
    super.key,
    required this.productos,
    required this.alCrear,
  });

  final List<Producto> productos;
  final VoidCallback alCrear;

  @override
  Widget build(BuildContext context) {
    final aLaVenta = productos.where((producto) => producto.aLaVenta).length;

    // Wrap baja los botones a un segundo renglón cuando no caben junto al
    // título (en teléfono).
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: 12,
          children: [
            Text('Productos', style: Tipografia.titulo(34)),
            Text(
              '$aLaVenta a la venta',
              style: Tipografia.texto(16, color: Colores.tintaSuave),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            BotonDeContorno(
              texto: 'Categorías',
              alto: 48,
              tamanoDeTexto: 16,
              // PENDIENTE: el diseño todavía no incluye la pantalla para
              // administrar categorías.
              alTocar: () => mostrarAvisoDePendiente(context, 'Categorías'),
            ),
            BotonPrincipal(
              texto: 'Nuevo producto',
              icono: Icons.add_rounded,
              alto: 48,
              tamanoDeTexto: 16,
              alTocar: alCrear,
            ),
          ],
        ),
      ],
    );
  }
}
