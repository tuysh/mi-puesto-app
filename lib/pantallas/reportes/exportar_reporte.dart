import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/pantallas/reportes/crear_pdf_del_reporte.dart';
import 'package:printing/printing.dart';

/// Arma el PDF del reporte del [periodo] que contiene a [fecha] y abre el
/// menú del teléfono para compartirlo o guardarlo. Si algo falla, avisa.
///
/// El PDF lo arma la aplicación con los datos del resumen; el servidor no
/// entrega PDF.
Future<void> exportarReporte(
  BuildContext context, {
  required Periodo periodo,
  required DateTime fecha,
}) async {
  final dependencias = Dependencias.de(context);

  try {
    final resumen = await dependencias.conexiones.resumen.obtenerResumen(
      periodo: periodo,
      fecha: fecha,
      // El PDF lleva todo, también la tabla por día.
      secciones: SeccionDeResumen.values.toSet(),
    );

    final pdf = await crearPdfDelReporte(
      nombreDelNegocio: dependencias.sesion.nombreDelNegocio,
      resumen: resumen,
      generadoEn: DateTime.now(),
    );
    await Printing.sharePdf(bytes: pdf, filename: nombreDelArchivo(resumen));
  } catch (error) {
    if (context.mounted) {
      mostrarAvisoDeError(
        context,
        error,
        siNoHayExplicacion: 'No se pudo crear el PDF',
      );
    }
  }
}
