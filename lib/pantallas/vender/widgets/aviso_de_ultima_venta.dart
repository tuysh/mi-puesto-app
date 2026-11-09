import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/pantallas/vender/widgets/aviso_de_venta_registrada.dart';

/// Muestra el aviso de "Venta registrada" mientras haya una venta recién
/// hecha. El aviso se queda hasta cerrarlo o empezar otro pedido.
class AvisoDeUltimaVenta extends StatelessWidget {
  const AvisoDeUltimaVenta({super.key});

  Future<void> _corregir(BuildContext context) async {
    try {
      await Dependencias.de(context).ventas.corregirUltimaVenta();
    } catch (_) {
      if (context.mounted) {
        mostrarAviso(context, 'No se pudo corregir la venta');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ventas = Dependencias.de(context).ventas;

    return ListenableBuilder(
      listenable: ventas,
      builder: (context, _) {
        final venta = ventas.ultimaVenta;
        if (venta == null) return const SizedBox.shrink();

        return AvisoDeVentaRegistrada(
          venta: venta,
          alCerrar: ventas.cerrarAviso,
          alCorregir: () => _corregir(context),
        );
      },
    );
  }
}
