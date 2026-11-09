import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/banda_de_monto.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/pantallas/cobrar/registrar_venta.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/boton_de_registrar_venta.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/pregunta_de_pago.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/selector_de_pago.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/tarjeta_de_pedido.dart';

/// Pantalla 4 (teléfono): muestra la cuenta, permite indicar con cuánto
/// pagó el cliente para calcular el cambio, y registra la venta.
class PantallaCobrar extends StatefulWidget {
  const PantallaCobrar({super.key});

  @override
  State<PantallaCobrar> createState() => _EstadoDePantallaCobrar();
}

class _EstadoDePantallaCobrar extends State<PantallaCobrar> {
  /// Con cuánto pagó el cliente; `null` significa que pagó exacto.
  Dinero? _pagoCon;

  bool _registrando = false;

  void _cambiarPago(Dinero? monto) {
    setState(() => _pagoCon = monto);
  }

  Future<void> _registrar() async {
    setState(() => _registrando = true);
    final seRegistro = await registrarVenta(context, pagoCon: _pagoCon);
    if (!mounted) return;

    if (seRegistro) {
      // De vuelta en "Vender" aparece el aviso con el cambio.
      cerrarPantalla(context);
    } else {
      setState(() => _registrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = Dependencias.de(context).pedido;
    final total = pedido.total;
    final pagoCon = _pagoCon;

    return Scaffold(
      body: SafeArea(
        child: AnchoMaximo(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: ColumnaConPie(
              pie: BotonDeRegistrarVenta(
                total: total,
                pagoCon: pagoCon,
                alTocar: _registrando ? null : _registrar,
              ),
              children: [
                const EncabezadoConVolver(titulo: 'Cobrar'),
                TarjetaDePedido(
                  lineas: pedido.lineas,
                  total: total,
                  alCambiarProductos: () => cerrarPantalla(context),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 6,
                  children: [
                    PreguntaDePago(
                      hayBilleteElegido: pagoCon != null,
                      alDecirQueFueExacto: () => _cambiarPago(null),
                    ),
                    SelectorDePago(
                      total: total,
                      pagoCon: pagoCon,
                      alCambiar: _cambiarPago,
                    ),
                  ],
                ),
                if (pagoCon != null)
                  BandaDeMonto(
                    etiqueta: 'Cambio',
                    monto: formatearDinero(pagoCon - total),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
