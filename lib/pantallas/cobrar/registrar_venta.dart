import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/avisos.dart';

/// Registra el pedido actual como venta. Si falla, avisa en pantalla.
///
/// [pagoCon] es con cuánto pagó el cliente; `null` significa pago exacto.
/// Devuelve `true` si la venta quedó registrada.
Future<bool> registrarVenta(BuildContext context, {Dinero? pagoCon}) async {
  try {
    await Dependencias.de(context).ventas.registrarVenta(pagoCon: pagoCon);
    return true;
  } catch (_) {
    if (context.mounted) mostrarAviso(context, 'No se pudo registrar la venta');
    return false;
  }
}
