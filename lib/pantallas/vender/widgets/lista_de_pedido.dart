import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/pantallas/vender/widgets/renglon_de_pedido.dart';

/// Todos los renglones del pedido actual, uno debajo de otro.
class ListaDePedido extends StatelessWidget {
  const ListaDePedido({super.key, this.ajustarAlContenido = false});

  /// Si es `true` la lista mide lo que miden sus renglones, en vez de
  /// ocupar todo el alto disponible. Hace falta dentro de una hoja.
  final bool ajustarAlContenido;

  @override
  Widget build(BuildContext context) {
    final dependencias = Dependencias.de(context);
    final pedido = dependencias.pedido;

    return ListenableBuilder(
      listenable: pedido,
      builder: (context, _) {
        if (pedido.estaVacio) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'Toca un producto para sumarlo',
              style: Tipografia.texto(15, color: Colores.tintaSuave),
            ),
          );
        }

        return ListView(
          shrinkWrap: ajustarAlContenido,
          children: [
            for (final linea in pedido.lineas)
              RenglonDePedido(
                linea: linea,
                fondoDelEmoji: dependencias.catalogo
                    .categoriaDe(linea.producto)
                    .colores
                    .fondo,
                alQuitar: () => pedido.quitar(linea.producto),
                alAgregar: () => pedido.agregar(linea.producto),
              ),
          ],
        );
      },
    );
  }
}
