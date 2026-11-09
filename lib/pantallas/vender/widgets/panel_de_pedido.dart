import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/cifra_con_doble_raya.dart';
import 'package:mi_puesto/pantallas/cobrar/registrar_venta.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/boton_de_registrar_venta.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/selector_de_pago.dart';
import 'package:mi_puesto/pantallas/vender/widgets/lista_de_pedido.dart';

/// En tablet: la columna derecha con el pedido completo y el cobro.
/// Hace en un solo lugar lo que en teléfono son la barra del pedido y la
/// pantalla "Cobrar".
class PanelDePedido extends StatefulWidget {
  const PanelDePedido({super.key});

  @override
  State<PanelDePedido> createState() => _EstadoDePanelDePedido();
}

class _EstadoDePanelDePedido extends State<PanelDePedido> {
  /// Con cuánto pagó el cliente; `null` significa que pagó exacto.
  Dinero? _pagoCon;

  Future<void> _registrar() async {
    final seRegistro = await registrarVenta(context, pagoCon: _pagoCon);
    if (seRegistro && mounted) setState(() => _pagoCon = null);
  }

  @override
  Widget build(BuildContext context) {
    final pedido = Dependencias.de(context).pedido;

    return Container(
      width: 380,
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: Colores.superficie,
        border: Border(left: BorderSide(color: Colores.borde)),
      ),
      child: ListenableBuilder(
        listenable: pedido,
        builder: (context, _) {
          final total = pedido.total;

          // Si el pedido creció después de elegir el billete, puede que ya
          // no alcance; en ese caso se ignora y se vuelve a "exacto".
          final pagoCon = _pagoCon;
          final pagoQueAlcanza = (pagoCon != null && pagoCon >= total)
              ? pagoCon
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Row(
                spacing: 10,
                children: [
                  Text('Pedido', style: Tipografia.titulo(24)),
                  BotonDeEnlace(texto: 'Vaciar', alTocar: pedido.vaciar),
                  const Spacer(),
                  CifraConDobleRaya(formatearDinero(total), tamano: 34),
                ],
              ),
              const Expanded(child: ListaDePedido()),
              SelectorDePago(
                total: total,
                pagoCon: pagoQueAlcanza,
                alCambiar: (monto) => setState(() => _pagoCon = monto),
                altoDeBoton: 48,
              ),
              BotonDeRegistrarVenta(
                total: total,
                pagoCon: pagoQueAlcanza,
                alTocar: pedido.estaVacio ? null : _registrar,
                alto: 62,
              ),
            ],
          );
        },
      ),
    );
  }
}
