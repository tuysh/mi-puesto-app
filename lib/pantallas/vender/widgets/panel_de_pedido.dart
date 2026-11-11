import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/cifra_con_doble_raya.dart';
import 'package:mi_puesto/pantallas/cobrar/registrar_venta.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/boton_de_registrar_venta.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/campo_de_nota.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/selector_de_metodo_de_pago.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/selector_de_pago.dart';
import 'package:mi_puesto/pantallas/vender/widgets/lista_de_pedido.dart';

/// En tablet: la columna derecha con el pedido completo y el cobro.
/// Hace en un solo lugar lo que en teléfono son las pantallas "Pedido" y
/// "Cobrar".
class PanelDePedido extends StatefulWidget {
  const PanelDePedido({super.key});

  @override
  State<PanelDePedido> createState() => _EstadoDePanelDePedido();
}

class _EstadoDePanelDePedido extends State<PanelDePedido> {
  MetodoDePago _metodo = MetodoDePago.efectivo;

  /// Con cuánto pagó el cliente; `null` significa que pagó exacto.
  Dinero? _pagoCon;

  final _nota = TextEditingController();

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  void _elegirMetodo(MetodoDePago metodo) {
    setState(() {
      _metodo = metodo;
      // Con tarjeta no hay billetes: se olvida el que estaba elegido.
      _pagoCon = null;
    });
  }

  Future<void> _registrar(Dinero? pagoQueAlcanza) async {
    final seRegistro = await registrarVenta(
      context,
      metodoDePago: _metodo,
      montoRecibido: pagoQueAlcanza,
      nota: _nota.text.trim(),
    );
    if (!seRegistro || !mounted) return;

    // Queda listo para el siguiente cliente.
    _nota.clear();
    setState(() {
      _metodo = MetodoDePago.efectivo;
      _pagoCon = null;
    });
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
                  // El total se pega a la derecha y, si es tan grande que
                  // no cabe en el renglón, FittedBox lo encoge.
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: CifraConDobleRaya(
                        formatearDinero(total),
                        tamano: 34,
                      ),
                    ),
                  ),
                ],
              ),
              const Expanded(
                child: SingleChildScrollView(
                  child: ListaDePedido(
                    altoDeRenglon: 55,
                    rayasPunteadas: false,
                  ),
                ),
              ),
              SelectorDeMetodoDePago(
                elegido: _metodo,
                alElegir: _elegirMetodo,
                grande: false,
              ),
              if (_metodo == MetodoDePago.efectivo)
                SelectorDePago(
                  total: total,
                  pagoCon: pagoQueAlcanza,
                  alCambiar: (monto) => setState(() => _pagoCon = monto),
                  altoDeBoton: 48,
                ),
              CampoDeNota(controlador: _nota),
              BotonDeRegistrarVenta(
                total: total,
                metodoDePago: _metodo,
                pagoCon: pagoQueAlcanza,
                alTocar: pedido.estaVacio
                    ? null
                    : () => _registrar(pagoQueAlcanza),
              ),
            ],
          );
        },
      ),
    );
  }
}
