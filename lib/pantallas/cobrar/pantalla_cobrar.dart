import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/banda_de_monto.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/cobrar/registrar_venta.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/boton_de_registrar_venta.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/campo_de_nota.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/pregunta_de_pago.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/selector_de_metodo_de_pago.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/selector_de_pago.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/tarjeta_de_pedido.dart';
import 'package:mi_puesto/pantallas/vender/pantalla_de_pedido.dart';

/// Pantalla 2.6 (teléfono): muestra la cuenta, pregunta cómo pagó el
/// cliente (y con cuánto, para calcular el cambio) y registra la venta.
class PantallaCobrar extends StatefulWidget {
  const PantallaCobrar({super.key});

  @override
  State<PantallaCobrar> createState() => _EstadoDePantallaCobrar();
}

class _EstadoDePantallaCobrar extends State<PantallaCobrar> {
  MetodoDePago _metodo = MetodoDePago.efectivo;

  /// Con cuánto pagó el cliente; `null` significa que pagó exacto.
  Dinero? _pagoCon;

  final _nota = TextEditingController();

  bool _registrando = false;

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

  void _cambiarPago(Dinero? monto) {
    setState(() => _pagoCon = monto);
  }

  Future<void> _registrar() async {
    setState(() => _registrando = true);
    final seRegistro = await registrarVenta(
      context,
      metodoDePago: _metodo,
      montoRecibido: _pagoCon,
      nota: _nota.text.trim(),
    );
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
    final esEfectivo = _metodo == MetodoDePago.efectivo;

    return MarcoDePantalla(
      child: ColumnaConPie(
        espacio: 14,
        pie: BotonDeRegistrarVenta(
          total: total,
          metodoDePago: _metodo,
          pagoCon: pagoCon,
          alTocar: _registrando ? null : _registrar,
        ),
        children: [
          const EncabezadoConVolver(titulo: 'Cobrar'),
          TarjetaDePedido(
            renglones: [
              for (final linea in pedido.lineas)
                (
                  concepto: '${linea.cantidad} × ${linea.nombreCompleto}',
                  subtotal: linea.subtotal,
                ),
            ],
            total: total,
            alPie: BotonDeEnlace(
              texto: 'Cambiar productos',
              // Se cambia esta pantalla por "Pedido": así, al volver desde
              // allá, se regresa directo a "Vender".
              alTocar: () =>
                  reemplazarPantalla(context, const PantallaDePedido()),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text('¿Cómo pagó?', style: Tipografia.texto(17, peso: 800)),
              SelectorDeMetodoDePago(elegido: _metodo, alElegir: _elegirMetodo),
            ],
          ),
          if (esEfectivo)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
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
            )
          else
            const TextoDeAyuda(
              'Cobra con tu terminal como siempre. Aquí solo se anota que '
              'fue con tarjeta; no entra a la caja.',
              tamano: 15,
              peso: 700,
            ),
          if (pagoCon != null)
            BandaDeMonto(
              etiqueta: 'Cambio',
              monto: formatearDinero(pagoCon - total),
              tamanoDeMonto: 40,
            ),
          CampoDeNota(controlador: _nota),
        ],
      ),
    );
  }
}
