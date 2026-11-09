import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/resumen_del_dia.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/widgets/renglon_de_monto.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_de_seccion.dart';

/// La tarjeta "Quién vendió": cuánto dinero ha vendido cada persona hoy.
class SeccionDeQuienVendio extends StatelessWidget {
  const SeccionDeQuienVendio({super.key, required this.ventas});

  final List<VentaPorVendedor> ventas;

  @override
  Widget build(BuildContext context) {
    return TarjetaDeSeccion(
      titulo: 'Quién vendió',
      children: [
        for (final venta in ventas)
          RenglonDeMonto(
            concepto: venta.nombre,
            monto: formatearDinero(venta.total),
          ),
      ],
    );
  }
}
