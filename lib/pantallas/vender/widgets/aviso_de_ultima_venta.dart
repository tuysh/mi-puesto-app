import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/pantallas/vender/widgets/aviso_de_venta_registrada.dart';
import 'package:mi_puesto/pantallas/ventas/pantalla_de_detalle_de_venta.dart';

/// Muestra el aviso de "Venta registrada" mientras haya una venta recién
/// hecha. El aviso se queda hasta cerrarlo o empezar otro pedido.
class AvisoDeUltimaVenta extends StatelessWidget {
  const AvisoDeUltimaVenta({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencias = Dependencias.de(context);
    final ventas = dependencias.ventas;

    return ListenableBuilder(
      listenable: ventas,
      builder: (context, _) {
        final venta = ventas.ultimaVenta;
        if (venta == null) return const SizedBox.shrink();

        return AvisoDeVentaRegistrada(
          venta: venta,
          alCerrar: ventas.cerrarAviso,
          // Solo la dueña puede corregir una venta.
          alVerOCorregir: dependencias.sesion.esDuena
              ? () => abrirPantalla(
                  context,
                  PantallaDeDetalleDeVenta(ventaId: venta.id),
                )
              : null,
        );
      },
    );
  }
}
