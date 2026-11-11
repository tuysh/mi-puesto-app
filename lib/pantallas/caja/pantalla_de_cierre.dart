import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/cifra_con_doble_raya.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/linea_punteada.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_de_seccion.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_elevada.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/caja/widgets/banda_de_diferencia.dart';
import 'package:mi_puesto/pantallas/caja/widgets/renglon_de_cuenta.dart';

/// Pantalla 3.6: lo que quedó guardado al cerrar una caja: las ventas por
/// método de pago, los gastos, lo que debía haber, lo que se contó y la
/// diferencia. Se abre al cerrar la caja y desde "Cierres anteriores".
class PantallaDeCierre extends StatelessWidget {
  const PantallaDeCierre({super.key, required this.cierre});

  /// La caja ya cerrada.
  final Caja cierre;

  /// "Miércoles 5 de noviembre · cerró Mari, 8:10 p. m."
  String _subtitulo(BuildContext context) {
    final fecha = formatearFechaLarga(cierre.fecha);
    final cerradaEn = cierre.cerradaEn;
    final cerradaPorId = cierre.cerradaPorId;
    if (cerradaEn == null || cerradaPorId == null) return fecha;

    final quien = Dependencias.de(context).sesion.nombreDe(cerradaPorId);
    return '$fecha · cerró $quien, ${formatearHora(cerradaEn)}';
  }

  @override
  Widget build(BuildContext context) {
    final nota = cierre.nota;
    final ventas = cierre.numeroDeVentas;

    return MarcoDePantalla(
      child: ColumnaConPie(
        espacio: 14,
        pie: const TextoDeAyuda(
          'Un día cerrado ya no se puede cambiar: sus ventas no se editan '
          'ni se cancelan.',
          centrado: true,
        ),
        children: [
          EncabezadoConVolver(
            titulo: 'Caja cerrada',
            subtitulo: _subtitulo(context),
          ),
          TarjetaDeSeccion(
            titulo: 'Ventas y gastos',
            children: [
              RenglonDeCuenta(
                concepto: 'Vendido en efectivo',
                monto: formatearDinero(cierre.ventasEnEfectivo),
              ),
              RenglonDeCuenta(
                concepto: 'Vendido con tarjeta',
                monto: formatearDinero(cierre.ventasConTarjeta),
              ),
              const LineaPunteada(),
              RenglonDeCuenta(
                concepto:
                    'Vendido · $ventas ${ventas == 1 ? 'venta' : 'ventas'}',
                monto: formatearDinero(cierre.vendido),
                fuerte: true,
              ),
              RenglonDeCuenta(
                concepto: 'Gastos del día',
                monto: formatearDinero(cierre.gastosTotales),
              ),
            ],
          ),
          TarjetaElevada(
            relleno: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Text('Caja', style: Tipografia.titulo(19, peso: 700)),
                RenglonDeCuenta(
                  concepto: 'Con lo que abriste',
                  monto: formatearDinero(cierre.fondoInicial),
                ),
                RenglonDeCuenta(
                  concepto: '+ Vendido en efectivo',
                  monto: formatearDinero(cierre.ventasEnEfectivo),
                ),
                RenglonDeCuenta(
                  concepto: '− Gastos pagados de la caja',
                  monto: formatearDinero(cierre.gastosDeCaja),
                ),
                const LineaPunteada(),
                RenglonDeCuenta(
                  concepto: 'Debía haber',
                  monto: formatearDinero(cierre.efectivoEsperado),
                  fuerte: true,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Contaste', style: Tipografia.texto(17, peso: 800)),
                    CifraConDobleRaya(
                      formatearDinero(cierre.efectivoContado ?? Dinero.cero),
                      tamano: 40,
                    ),
                  ],
                ),
              ],
            ),
          ),
          BandaDeDiferencia(
            diferencia: cierre.diferencia ?? Dinero.cero,
            detalleSiNoCuadra: nota.isEmpty ? null : 'Nota: «$nota»',
          ),
        ],
      ),
    );
  }
}
