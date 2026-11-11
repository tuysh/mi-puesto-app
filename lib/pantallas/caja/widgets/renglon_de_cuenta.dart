import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';

/// Un renglón de la cuenta de la caja: el concepto a la izquierda y su
/// monto a la derecha. El renglón de una suma va [fuerte].
class RenglonDeCuenta extends StatelessWidget {
  const RenglonDeCuenta({
    super.key,
    required this.concepto,
    required this.monto,
    this.tamano = 16,
    this.fuerte = false,
  });

  final String concepto;

  /// El monto ya convertido a texto, por ejemplo `$500`.
  final String monto;

  final double tamano;

  /// Con `true` el concepto va más grueso: es un subtotal.
  final bool fuerte;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: Text(
            concepto,
            style: Tipografia.texto(tamano, peso: fuerte ? 800 : 700),
          ),
        ),
        Cifra(monto, tamano: tamano),
      ],
    );
  }
}
