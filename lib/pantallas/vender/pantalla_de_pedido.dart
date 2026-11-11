import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/cifra_con_doble_raya.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_elevada.dart';
import 'package:mi_puesto/pantallas/cobrar/pantalla_cobrar.dart';
import 'package:mi_puesto/pantallas/vender/widgets/lista_de_pedido.dart';

/// Pantalla 2.5 (teléfono): el pedido como hoja de libreta. Un renglón por
/// producto (y por tamaño), con botones para quitar o agregar piezas, y el
/// total con doble raya.
class PantallaDePedido extends StatelessWidget {
  const PantallaDePedido({super.key});

  void _vaciar(BuildContext context) {
    Dependencias.de(context).pedido.vaciar();
    // Sin pedido no hay nada que ver aquí: de vuelta a "Vender".
    cerrarPantalla(context);
  }

  @override
  Widget build(BuildContext context) {
    final pedido = Dependencias.de(context).pedido;

    return MarcoDePantalla(
      child: ListenableBuilder(
        listenable: pedido,
        builder: (context, _) {
          final piezas = pedido.piezas;
          final palabra = piezas == 1 ? 'producto' : 'productos';
          final total = formatearDinero(pedido.total);

          return ColumnaConPie(
            pie: BotonPrincipal(
              texto: 'Cobrar $total',
              icono: Icons.arrow_forward_rounded,
              iconoAlFinal: true,
              // Se cambia esta pantalla por "Cobrar": así, al volver
              // desde allá, se regresa directo a "Vender".
              alTocar: pedido.estaVacio
                  ? null
                  : () => reemplazarPantalla(context, const PantallaCobrar()),
            ),
            children: [
              EncabezadoConVolver(
                titulo: 'Pedido',
                accion: BotonDeEnlace(
                  texto: 'Vaciar',
                  alTocar: () => _vaciar(context),
                ),
              ),
              TarjetaElevada(
                relleno: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ListaDePedido(),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 12,
                      children: [
                        Expanded(
                          child: Text(
                            'Total · $piezas $palabra',
                            style: Tipografia.texto(18, peso: 800),
                          ),
                        ),
                        CifraConDobleRaya(total, tamano: 44),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
