import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';

/// El botón que registra la venta. Su texto dice cómo se pagó:
/// "Registrar con tarjeta $125", "Registrar exacto $125" o, si se eligió
/// un billete, "Registrar $125".
class BotonDeRegistrarVenta extends StatelessWidget {
  const BotonDeRegistrarVenta({
    super.key,
    required this.total,
    required this.metodoDePago,
    required this.pagoCon,
    required this.alTocar,
    this.alto = 64,
  });

  final Dinero total;
  final MetodoDePago metodoDePago;

  /// Con cuánto pagó el cliente; `null` significa que pagó exacto.
  final Dinero? pagoCon;

  final VoidCallback? alTocar;
  final double alto;

  String get _texto {
    final monto = formatearDinero(total);

    if (metodoDePago == MetodoDePago.tarjeta) {
      return 'Registrar con tarjeta $monto';
    }
    return pagoCon == null ? 'Registrar exacto $monto' : 'Registrar $monto';
  }

  @override
  Widget build(BuildContext context) {
    return BotonPrincipal(
      texto: _texto,
      icono: Icons.check_rounded,
      iconoAlFinal: true,
      alTocar: alTocar,
      alto: alto,
      // Con tarjeta el texto es más largo: un punto menos para que quepa.
      tamanoDeTexto: metodoDePago == MetodoDePago.tarjeta ? 20 : 22,
    );
  }
}
