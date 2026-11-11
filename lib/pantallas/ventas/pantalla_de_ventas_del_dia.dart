import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/fechas.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/fila_de_lista.dart';
import 'package:mi_puesto/nucleo/widgets/fila_de_lista_vacia.dart';
import 'package:mi_puesto/nucleo/widgets/lista_en_tarjeta.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/navegador_de_fechas.dart';
import 'package:mi_puesto/nucleo/widgets/resumen_de_lista.dart';
import 'package:mi_puesto/pantallas/ventas/pantalla_de_detalle_de_venta.dart';
import 'package:mi_puesto/pantallas/ventas/widgets/marca_de_venta.dart';

/// Pantalla 3.2: las ventas de un día, de todos los que vendieron. Con las
/// flechas se va a otros días. Al tocar una venta se abre su detalle.
///
/// Una venta cancelada sigue en la lista, tachada, y no suma.
class PantallaDeVentasDelDia extends StatefulWidget {
  const PantallaDeVentasDelDia({super.key});

  @override
  State<PantallaDeVentasDelDia> createState() =>
      _EstadoDePantallaDeVentasDelDia();
}

class _EstadoDePantallaDeVentasDelDia extends State<PantallaDeVentasDelDia> {
  DateTime _fecha = hoy();

  /// Cambia cada vez que se vuelve del detalle de una venta, para que la
  /// lista se pida otra vez (la venta pudo editarse o cancelarse).
  int _version = 0;

  bool get _esHoy => esElMismoDia(_fecha, DateTime.now());

  void _moverDias(int dias) {
    setState(() => _fecha = sumarDias(_fecha, dias));
  }

  Future<void> _abrir(Venta venta) async {
    await abrirPantalla(context, PantallaDeDetalleDeVenta(ventaId: venta.id));
    if (mounted) setState(() => _version++);
  }

  @override
  Widget build(BuildContext context) {
    final repositorio = Dependencias.de(context).conexiones.ventas;

    return MarcoDePantalla(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          const EncabezadoConVolver(titulo: 'Ventas del día'),
          NavegadorDeFechas(
            enTarjeta: true,
            texto: formatearFechaConHoy(_fecha),
            alIrAlAnterior: () => _moverDias(-1),
            // No hay ventas del futuro: en hoy, la flecha se apaga.
            alIrAlSiguiente: _esHoy ? null : () => _moverDias(1),
          ),
          Expanded(
            child: CargadorDeFuturo<VentasDelDia>(
              // Con otra llave se vuelve a pedir: otro día u otra versión.
              key: ValueKey((_fecha, _version)),
              cargar: () => repositorio.obtenerVentasDelDia(_fecha),
              construir: (context, ventasDelDia) =>
                  _construirLista(ventasDelDia),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirLista(VentasDelDia ventasDelDia) {
    final sesion = Dependencias.de(context).sesion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        ResumenDeLista(
          texto: _textoDeCuantas(ventasDelDia),
          total: formatearDinero(ventasDelDia.total),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: ListaEnTarjeta(
              children: [
                if (ventasDelDia.ventas.isEmpty)
                  const FilaDeListaVacia('No hay ventas este día.'),
                for (final venta in ventasDelDia.ventas)
                  FilaDeLista(
                    titulo: formatearHora(venta.creadaEn),
                    juntoAlTitulo: MarcaDeVenta.haceFaltaPara(venta)
                        ? MarcaDeVenta(venta: venta)
                        : null,
                    detalle:
                        '${sesion.nombreDe(venta.perfilId)} · '
                        '${venta.metodoDePago.etiqueta}',
                    monto: formatearDinero(venta.total),
                    montoTachado: venta.estaCancelada,
                    alTocar: () => _abrir(venta),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// "23 ventas · 1 cancelada"
  String _textoDeCuantas(VentasDelDia ventasDelDia) {
    final cuantas = ventasDelDia.cuantas;
    final canceladas = ventasDelDia.canceladas;

    final ventas = '$cuantas ${cuantas == 1 ? 'venta' : 'ventas'}';
    if (canceladas == 0) return ventas;

    return '$ventas · $canceladas '
        '${canceladas == 1 ? 'cancelada' : 'canceladas'}';
  }
}
