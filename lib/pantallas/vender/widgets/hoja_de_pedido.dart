import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/pantallas/vender/widgets/lista_de_pedido.dart';

/// En teléfono: abre desde abajo una hoja con el detalle del pedido, donde
/// se pueden quitar o agregar piezas.
void mostrarHojaDePedido(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colores.superficie,
    showDragHandle: true,
    builder: (context) => const _HojaDePedido(),
  );
}

class _HojaDePedido extends StatelessWidget {
  const _HojaDePedido();

  void _vaciar(BuildContext context) {
    Dependencias.de(context).pedido.vaciar();
    cerrarPantalla(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: 10,
              children: [
                Text('Pedido', style: Tipografia.titulo(24)),
                BotonDeEnlace(texto: 'Vaciar', alTocar: () => _vaciar(context)),
              ],
            ),
            const Flexible(child: ListaDePedido(ajustarAlContenido: true)),
          ],
        ),
      ),
    );
  }
}
