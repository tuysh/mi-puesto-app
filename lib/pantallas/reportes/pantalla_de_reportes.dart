import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/nucleo/fechas.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/navegador_de_fechas.dart';
import 'package:mi_puesto/nucleo/widgets/selector_de_segmentos.dart';
import 'package:mi_puesto/pantallas/gastos/pantalla_de_gastos.dart';
import 'package:mi_puesto/pantallas/hoy/widgets/seccion_de_mas_vendidos.dart';
import 'package:mi_puesto/pantallas/reportes/exportar_reporte.dart';
import 'package:mi_puesto/pantallas/reportes/fechas_de_periodo.dart';
import 'package:mi_puesto/pantallas/reportes/widgets/seccion_de_gastos_por_categoria.dart';
import 'package:mi_puesto/pantallas/reportes/widgets/tarjeta_de_utilidad.dart';

/// Pantalla 4.3: la cuenta de un día, una semana o un mes (vendido −
/// gastos = utilidad), lo más vendido y en qué se fueron los gastos. Con
/// las flechas se va a periodos anteriores, y se puede exportar a PDF.
class PantallaDeReportes extends StatefulWidget {
  const PantallaDeReportes({super.key});

  @override
  State<PantallaDeReportes> createState() => _EstadoDePantallaDeReportes();
}

class _EstadoDePantallaDeReportes extends State<PantallaDeReportes> {
  Periodo _periodo = Periodo.semana;

  /// Un día cualquiera del periodo que se está mirando.
  DateTime _fecha = hoy();

  OrdenDeProductos _orden = OrdenDeProductos.cantidad;

  bool _exportando = false;

  void _mover(int pasos) {
    setState(() => _fecha = moverDePeriodo(_periodo, _fecha, pasos));
  }

  void _elegirPeriodo(Periodo periodo) {
    setState(() {
      _periodo = periodo;
      // Al cambiar de periodo se vuelve al de hoy.
      _fecha = hoy();
    });
  }

  Future<void> _exportar() async {
    setState(() => _exportando = true);
    await exportarReporte(context, periodo: _periodo, fecha: _fecha);
    if (mounted) setState(() => _exportando = false);
  }

  @override
  Widget build(BuildContext context) {
    final repositorio = Dependencias.de(context).conexiones.resumen;

    return AnchoMaximo(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              children: [
                Expanded(child: Text('Reportes', style: Tipografia.titulo(32))),
                BotonDeContorno(
                  texto: 'Exportar PDF',
                  icono: Icons.download_rounded,
                  alto: 44,
                  tamanoDeTexto: 15,
                  alTocar: _exportando ? null : _exportar,
                ),
              ],
            ),
            SelectorDeSegmentos<Periodo>(
              opciones: {
                for (final periodo in Periodo.values) periodo: periodo.etiqueta,
              },
              elegida: _periodo,
              alElegir: _elegirPeriodo,
            ),
            NavegadorDeFechas(
              texto: textoDePeriodo(_periodo, _fecha),
              alIrAlAnterior: () => _mover(-1),
              // No hay ventas del futuro: en el periodo de hoy, se apaga.
              alIrAlSiguiente: esElPeriodoActual(_periodo, _fecha)
                  ? null
                  : () => _mover(1),
            ),
            Expanded(
              child: CargadorDeFuturo<Resumen>(
                // Con otra llave se vuelve a pedir: otro periodo, otra
                // fecha u otro orden.
                key: ValueKey((_periodo, _fecha, _orden)),
                cargar: () => repositorio.obtenerResumen(
                  periodo: _periodo,
                  fecha: _fecha,
                  // Todo menos "por día", que solo sale en el PDF.
                  secciones: {
                    SeccionDeResumen.totales,
                    SeccionDeResumen.masVendidos,
                    SeccionDeResumen.gastosPorCategoria,
                  },
                  orden: _orden,
                ),
                construir: (context, resumen) => _construirResumen(resumen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirResumen(Resumen resumen) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        TarjetaDeUtilidad(totales: resumen.totales),
        const SizedBox(height: 12),
        SeccionDeMasVendidos(
          productos: resumen.masVendidos,
          orden: _orden,
          // Los más vendidos se pueden ordenar por piezas o por dinero:
          // no siempre gana el mismo.
          alLadoDelTitulo: SelectorDeSegmentos<OrdenDeProductos>(
            opciones: {
              for (final orden in OrdenDeProductos.values)
                orden: orden.etiqueta,
            },
            elegida: _orden,
            alElegir: (orden) => setState(() => _orden = orden),
            alto: 36,
            tamanoDeTexto: 14,
            ocuparTodoElAncho: false,
          ),
        ),
        const SizedBox(height: 12),
        SeccionDeGastosPorCategoria(
          gastos: resumen.gastosPorCategoria,
          alVerTodos: () => abrirPantalla(context, const PantallaDeGastos()),
        ),
      ],
    );
  }
}
