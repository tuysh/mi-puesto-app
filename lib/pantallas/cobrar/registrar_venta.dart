import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/avisos.dart';

/// Registra el pedido actual como venta. Si falla, avisa en pantalla.
///
/// [montoRecibido] es con cuánto pagó el cliente; `null` significa pago
/// exacto. Devuelve `true` si la venta quedó registrada.
Future<bool> registrarVenta(
  BuildContext context, {
  required MetodoDePago metodoDePago,
  Dinero? montoRecibido,
  String nota = '',
}) async {
  final dependencias = Dependencias.de(context);

  try {
    await dependencias.ventas.registrarVenta(
      metodoDePago: metodoDePago,
      montoRecibido: montoRecibido,
      nota: nota,
    );
    return true;
  } catch (error) {
    // Si alguien cerró la caja mientras tanto, "Vender" tiene que
    // enterarse para dejar de ofrecer productos.
    final seCerroLaCaja =
        error is ErrorDelServidor && error.codigo == CodigosDeError.sinCaja;
    if (seCerroLaCaja) dependencias.caja.actualizar();

    if (context.mounted) {
      mostrarAvisoDeError(
        context,
        error,
        siNoHayExplicacion: 'No se pudo registrar la venta',
      );
    }
    return false;
  }
}
