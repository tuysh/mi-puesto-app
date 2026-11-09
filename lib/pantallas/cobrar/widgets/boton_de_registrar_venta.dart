import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';

/// El botón que registra la venta. Su texto dice si el pago fue exacto:
/// "Registrar exacto $125" o, si se eligió un billete, "Registrar $125".
class BotonDeRegistrarVenta extends StatelessWidget {
  const BotonDeRegistrarVenta({
    super.key,
    required this.total,
    required this.pagoCon,
    required this.alTocar,
    this.alto = 64,
  });

  final Dinero total;

  /// Con cuánto pagó el cliente; `null` significa que pagó exacto.
  final Dinero? pagoCon;

  final VoidCallback? alTocar;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final pagoExacto = pagoCon == null;
    final monto = formatearDinero(total);

    return BotonPrincipal(
      texto: pagoExacto ? 'Registrar exacto $monto' : 'Registrar $monto',
      icono: Icons.check_rounded,
      iconoAlFinal: true,
      alTocar: alTocar,
      alto: alto,
    );
  }
}
