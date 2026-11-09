import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/vendedor.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/avatar_de_inicial.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Tarjeta grande con la inicial y el nombre de una persona.
class TarjetaDeVendedor extends StatelessWidget {
  const TarjetaDeVendedor({
    super.key,
    required this.vendedor,
    required this.alTocar,
  });

  final Vendedor vendedor;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      radio: Radios.tarjetaGrande,
      decoracion: BoxDecoration(
        color: Colores.superficie,
        boxShadow: Sombras.dura(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          AvatarDeInicial(
            inicial: vendedor.inicial,
            colores: vendedor.colores,
            tamano: 72,
          ),
          Text(
            vendedor.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Tipografia.texto(19, peso: 800),
          ),
        ],
      ),
    );
  }
}
