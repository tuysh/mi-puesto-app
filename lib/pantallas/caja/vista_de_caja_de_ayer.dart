import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/banda_de_aviso.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';
import 'package:mi_puesto/pantallas/caja/pantalla_de_cerrar_caja.dart';

/// Pantalla 2.1 (variante): lo que ve la dueña en "Vender" cuando la caja
/// abierta es de un día anterior. Solo hay una caja abierta a la vez, así
/// que antes de abrir la de hoy hay que cerrar esa.
class VistaDeCajaDeAyer extends StatelessWidget {
  const VistaDeCajaDeAyer({super.key, required this.alSeguirVendiendo});

  /// La dueña prefiere no cerrarla todavía (por ejemplo, el puesto sigue
  /// abierto pasada la medianoche).
  final VoidCallback alSeguirVendiendo;

  @override
  Widget build(BuildContext context) {
    return AnchoMaximo(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
        child: ColumnaConPie(
          espacio: 18,
          pie: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              BotonPrincipal(
                texto: 'Cerrar la caja de ayer',
                alTocar: () =>
                    abrirPantalla(context, const PantallaDeCerrarCaja()),
              ),
              Center(
                child: BotonDeEnlace(
                  texto: 'Seguir vendiendo por ahora',
                  alTocar: alSeguirVendiendo,
                ),
              ),
            ],
          ),
          children: [
            EncabezadoDePantalla(
              sobretitulo: formatearFechaLarga(DateTime.now()),
              titulo: 'Antes cierra la caja de ayer',
              tamanoDeTitulo: 34,
            ),
            const BandaDeAviso(
              colores: Colores.alerta,
              titulo: 'La caja de ayer sigue abierta',
              explicacion:
                  'Las ventas se siguen anotando en el día de ayer hasta '
                  'que lo cierres. Después podrás abrir la de hoy.',
            ),
          ],
        ),
      ),
    );
  }
}
