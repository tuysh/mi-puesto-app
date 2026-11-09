import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/reporte.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_de_seccion.dart';
import 'package:mi_puesto/pantallas/reportes/widgets/renglon_de_categoria.dart';

/// La tarjeta "Por categoría": cuánto vendió cada categoría en el periodo.
class SeccionPorCategoria extends StatelessWidget {
  const SeccionPorCategoria({super.key, required this.ventas});

  final List<VentaPorCategoria> ventas;

  @override
  Widget build(BuildContext context) {
    return TarjetaDeSeccion(
      titulo: 'Por categoría',
      children: [
        for (final venta in ventas)
          RenglonDeCategoria(
            nombre: venta.categoria.etiqueta,
            colores: venta.categoria.colores,
            monto: formatearDinero(venta.total),
            // PENDIENTE: el diseño todavía no incluye el detalle de una
            // categoría.
            alTocar: () => mostrarAvisoDePendiente(
              context,
              'Detalle de ${venta.categoria.nombre}',
            ),
          ),
      ],
    );
  }
}
