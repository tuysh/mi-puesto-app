import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/reporte.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';
import 'package:mi_puesto/pantallas/reportes/widgets/grafica_de_ventas.dart';
import 'package:mi_puesto/pantallas/reportes/widgets/seccion_por_categoria.dart';
import 'package:mi_puesto/pantallas/reportes/widgets/selector_de_periodo.dart';
import 'package:mi_puesto/pantallas/reportes/widgets/tarjeta_de_total_del_periodo.dart';

/// Pantalla 7: las ventas del día, la semana o el mes, con una gráfica y
/// el desglose por categoría.
class PantallaDeReportes extends StatefulWidget {
  const PantallaDeReportes({super.key});

  @override
  State<PantallaDeReportes> createState() => _EstadoDePantallaDeReportes();
}

class _EstadoDePantallaDeReportes extends State<PantallaDeReportes> {
  Periodo _periodo = Periodo.semana;

  void _elegirPeriodo(Periodo periodo) {
    setState(() => _periodo = periodo);
  }

  @override
  Widget build(BuildContext context) {
    final repositorio = Dependencias.de(context).conexiones.reportes;
    const espacio = SizedBox(height: 14);

    return AnchoMaximo(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
        children: [
          const EncabezadoDePantalla(titulo: 'Reportes'),
          espacio,
          SelectorDePeriodo(elegido: _periodo, alElegir: _elegirPeriodo),
          espacio,
          CargadorDeFuturo<Reporte>(
            // Al cambiar la clave, el cargador se crea de nuevo y pide el
            // reporte del periodo recién elegido.
            key: ValueKey(_periodo),
            cargar: () => repositorio.obtenerReporte(_periodo),
            construir: (context, reporte) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                TarjetaDeTotalDelPeriodo(reporte: reporte),
                GraficaDeVentas(
                  titulo: reporte.periodo.tituloDeLaGrafica,
                  tramos: reporte.tramos,
                ),
                SeccionPorCategoria(ventas: reporte.ventasPorCategoria),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
