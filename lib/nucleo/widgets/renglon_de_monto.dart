import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';

/// Un renglón de cuenta: el concepto a la izquierda y su monto a la derecha.
class RenglonDeMonto extends StatelessWidget {
  const RenglonDeMonto({
    super.key,
    required this.concepto,
    required this.monto,
    this.tamano = 16,
  });

  final String concepto;

  /// El monto ya convertido a texto, por ejemplo `$90`.
  final String monto;

  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Expanded(child: Text(concepto, style: Tipografia.texto(tamano))),
        Cifra(monto, tamano: tamano),
      ],
    );
  }
}
