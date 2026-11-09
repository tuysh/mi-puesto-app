import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';

/// El lapso de tiempo que cubre un reporte.
enum Periodo {
  dia(
    etiqueta: 'Día',
    tituloDelTotal: 'Vendido hoy',
    tituloDeLaGrafica: 'Por hora',
  ),
  semana(
    etiqueta: 'Semana',
    tituloDelTotal: 'Vendido esta semana',
    tituloDeLaGrafica: 'Por día',
  ),
  mes(
    etiqueta: 'Mes',
    tituloDelTotal: 'Vendido este mes',
    tituloDeLaGrafica: 'Por semana',
  );

  const Periodo({
    required this.etiqueta,
    required this.tituloDelTotal,
    required this.tituloDeLaGrafica,
  });

  final String etiqueta;
  final String tituloDelTotal;
  final String tituloDeLaGrafica;
}

/// Las ventas de un [Periodo], listas para la pantalla "Reportes".
class Reporte {
  const Reporte({
    required this.periodo,
    required this.vendido,
    required this.ganancia,
    required this.tramos,
    required this.ventasPorCategoria,
  });

  final Periodo periodo;
  final Dinero vendido;
  final Dinero ganancia;

  /// Las barras de la gráfica, en orden de tiempo.
  final List<TramoDeReporte> tramos;

  final List<VentaPorCategoria> ventasPorCategoria;
}

/// Un par de barras de la gráfica: una hora, un día o una semana.
class TramoDeReporte {
  const TramoDeReporte({
    required this.etiqueta,
    required this.vendido,
    required this.ganancia,
    this.esActual = false,
  });

  /// Texto corto bajo las barras: "L", "M", "9h", "S1"…
  final String etiqueta;

  final Dinero vendido;
  final Dinero ganancia;

  /// `true` en el tramo de ahora (por ejemplo, el día de hoy).
  final bool esActual;
}

/// Cuánto dinero se vendió de una categoría.
class VentaPorCategoria {
  const VentaPorCategoria({required this.categoria, required this.total});

  final Categoria categoria;
  final Dinero total;
}
