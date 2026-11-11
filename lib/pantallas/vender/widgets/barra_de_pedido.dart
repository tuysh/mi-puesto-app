import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/pantallas/cobrar/pantalla_cobrar.dart';
import 'package:mi_puesto/pantallas/vender/widgets/boton_de_cobrar.dart';
import 'package:mi_puesto/pantallas/vender/pantalla_de_pedido.dart';

/// En teléfono: la barra con el resumen del pedido (piezas y total) y el
/// botón "Cobrar". No se dibuja mientras el pedido está vacío.
class BarraDePedido extends StatelessWidget {
  const BarraDePedido({super.key});

  @override
  Widget build(BuildContext context) {
    final pedido = Dependencias.de(context).pedido;

    return ListenableBuilder(
      listenable: pedido,
      builder: (context, _) {
        if (pedido.estaVacio) return const SizedBox.shrink();

        final piezas = pedido.piezas;
        final palabra = piezas == 1 ? 'producto' : 'productos';

        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colores.superficie,
            borderRadius: BorderRadius.circular(Radios.tarjeta),
            border: Border.all(color: Colores.tinta, width: 2),
            boxShadow: Sombras.dura(color: Colores.tinta),
          ),
          child: Row(
            // "stretch" hace que el botón Cobrar ocupe todo el alto.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ResumenTocable(
                  textoDePiezas: '$piezas $palabra · ver',
                  total: formatearDinero(pedido.total),
                  alTocar: () =>
                      abrirPantalla(context, const PantallaDePedido()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(7),
                child: BotonDeCobrar(
                  alTocar: () => abrirPantalla(context, const PantallaCobrar()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// La mitad izquierda de la barra. Al tocarla se abre la pantalla "Pedido".
class _ResumenTocable extends StatelessWidget {
  const _ResumenTocable({
    required this.textoDePiezas,
    required this.total,
    required this.alTocar,
  });

  final String textoDePiezas;
  final String total;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      radio: Radios.tarjeta,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(
              textoDePiezas,
              maxLines: 1,
              style: Tipografia.texto(15, peso: 800, altura: 1.15).copyWith(
                decoration: TextDecoration.underline,
                decorationThickness: 2,
              ),
            ),
            Cifra(total, tamano: 24, peso: 750),
          ],
        ),
      ),
    );
  }
}
