import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/nucleo/fechas.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/banda_de_aviso.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';
import 'package:mi_puesto/pantallas/caja/pantalla_de_cerrar_caja.dart';
import 'package:mi_puesto/pantallas/gastos/pantalla_de_gasto.dart';
import 'package:mi_puesto/pantallas/hoy/widgets/seccion_de_mas_vendidos.dart';
import 'package:mi_puesto/pantallas/hoy/widgets/tarjeta_de_dato.dart';
import 'package:mi_puesto/pantallas/hoy/widgets/tarjeta_de_vendido_hoy.dart';

/// Pantalla 3.1: cómo va el día: si la caja está abierta, lo vendido, los
/// gastos, la utilidad y lo más vendido. Desde aquí se anota un gasto y se
/// cierra la caja.
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _EstadoDePantallaHoy();
}

class _EstadoDePantallaHoy extends State<PantallaHoy> {
  /// Cambia cada vez que se vuelve de anotar un gasto o de cerrar la caja,
  /// para que los números se pidan otra vez.
  int _version = 0;

  /// Pide a la vez la caja y el resumen del día.
  Future<(Caja?, Resumen)> _cargar() async {
    final dependencias = Dependencias.de(context);

    final pedidoDeCaja = dependencias.caja.actualizar();
    final pedidoDeResumen = dependencias.conexiones.resumen.obtenerResumen(
      periodo: Periodo.dia,
      fecha: hoy(),
      // Solo lo que esta pantalla pinta: cada sección cuesta consultas.
      secciones: {SeccionDeResumen.totales, SeccionDeResumen.masVendidos},
      cuantosProductos: 3,
    );

    await pedidoDeCaja;
    return (dependencias.caja.caja, await pedidoDeResumen);
  }

  Future<void> _abrirYRecargar(Widget pantalla) async {
    await abrirPantalla(context, pantalla);
    if (mounted) setState(() => _version++);
  }

  @override
  Widget build(BuildContext context) {
    return AnchoMaximo(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 14),
        child: CargadorDeFuturo<(Caja?, Resumen)>(
          key: ValueKey(_version),
          cargar: _cargar,
          construir: (context, datos) {
            final (caja, resumen) = datos;
            return _construirResumen(caja, resumen);
          },
        ),
      ),
    );
  }

  Widget _construirResumen(Caja? caja, Resumen resumen) {
    final totales = resumen.totales;
    final hayPerdida = totales.utilidad.esNegativo;

    return ColumnaConPie(
      espacio: 12,
      pie: Row(
        spacing: 10,
        children: [
          Expanded(
            child: BotonDeContorno(
              texto: 'Anotar gasto',
              alTocar: () => _abrirYRecargar(const PantallaDeGasto()),
            ),
          ),
          // Sin caja abierta no hay nada que cerrar: se abre en "Vender".
          if (caja != null)
            Expanded(
              child: BotonDeContorno(
                texto: 'Cerrar caja',
                icono: Icons.lock_outline_rounded,
                alTocar: () => _abrirYRecargar(const PantallaDeCerrarCaja()),
              ),
            ),
        ],
      ),
      children: [
        EncabezadoDePantalla(
          sobretitulo: formatearFechaLarga(DateTime.now()),
          titulo: 'Hoy',
        ),
        if (caja == null)
          const BandaDeAviso(
            colores: Colores.alerta,
            titulo: 'La caja está cerrada · ábrela en Vender',
          )
        else
          BandaDeAviso(
            titulo:
                'Caja abierta · abriste con '
                '${formatearDinero(caja.fondoInicial)}',
          ),
        TarjetaDeVendidoHoy(totales: totales),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: TarjetaDeDato(
                etiqueta: 'Gastos',
                valor: formatearDinero(totales.gastos),
              ),
            ),
            Expanded(
              child: TarjetaDeDato(
                etiqueta: 'Utilidad',
                valor: formatearDinero(totales.utilidad),
                // Verde si se gana; ámbar si los gastos superan lo vendido.
                colores: hayPerdida ? Colores.alerta : Colores.exito,
              ),
            ),
          ],
        ),
        SeccionDeMasVendidos(
          productos: resumen.masVendidos,
          orden: OrdenDeProductos.cantidad,
        ),
      ],
    );
  }
}
