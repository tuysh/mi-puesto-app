/// Arma el PDF del reporte (pantalla 4.4 del diseño): una hoja carta con la
/// cuenta del periodo, la tabla por día, lo más vendido y los gastos por
/// categoría.
///
/// Va en tinta negra sobre blanco: debe leerse igual impreso en blanco y
/// negro.
///
/// OJO: aquí los widgets son los del paquete `pdf` (se escriben con el
/// prefijo `pw.`), no los de Flutter. Se parecen mucho, pero no son los
/// mismos: no se pueden mezclar con los de `nucleo/widgets`.
library;

import 'dart:typed_data';

import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const _tinta = PdfColor.fromInt(0xFF24181F);
const _tintaSuave = PdfColor.fromInt(0xFF5F4F58);
const _raya = PdfColor.fromInt(0xFFCDBFC4);

/// Devuelve el contenido del archivo PDF.
Future<Uint8List> crearPdfDelReporte({
  required String nombreDelNegocio,
  required Resumen resumen,
  required DateTime generadoEn,
}) {
  final documento = pw.Document(title: _tituloDe(resumen.periodo));

  documento.addPage(
    // MultiPage: si la tabla por día no cabe (un mes), sigue en otra hoja.
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.fromLTRB(42, 36, 42, 30),
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
      footer: _construirPie,
      build: (contexto) => [
        _construirEncabezado(nombreDelNegocio, resumen, generadoEn),
        pw.SizedBox(height: 18),
        _construirCuenta(resumen.totales),
        pw.SizedBox(height: 18),
        _construirTitulo('Por día'),
        _construirTablaPorDia(resumen),
        pw.SizedBox(height: 18),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _construirTitulo('Lo más vendido'),
                  _construirTablaDeMasVendidos(resumen.masVendidos),
                ],
              ),
            ),
            pw.SizedBox(width: 24),
            pw.Expanded(
              flex: 2,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _construirTitulo('Gastos por categoría'),
                  _construirTablaDeGastos(resumen.gastosPorCategoria),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );

  return documento.save();
}

/// El nombre con el que se guarda el archivo:
/// `reporte-semana-2026-11-03.pdf`.
String nombreDelArchivo(Resumen resumen) {
  final desde = resumen.desde;
  final mes = desde.month.toString().padLeft(2, '0');
  final dia = desde.day.toString().padLeft(2, '0');
  return 'reporte-${resumen.periodo.name}-${desde.year}-$mes-$dia.pdf';
}

String _tituloDe(Periodo periodo) {
  return switch (periodo) {
    Periodo.dia => 'Reporte del día',
    Periodo.semana => 'Reporte de la semana',
    Periodo.mes => 'Reporte del mes',
  };
}

/// Las fechas que cubre el reporte, como texto.
String _fechasDe(Resumen resumen) {
  return switch (resumen.periodo) {
    Periodo.dia => formatearFechaLarga(resumen.desde),
    Periodo.semana => formatearRango(resumen.desde, resumen.hasta),
    Periodo.mes => formatearMes(resumen.desde),
  };
}

/// El dinero como se escribe en el PDF. Los negativos van con guion.
String _dinero(Dinero monto) => formatearDinero(monto);

pw.TextStyle _estilo(double tamano, {bool fuerte = false, PdfColor? color}) {
  return pw.TextStyle(
    fontSize: tamano,
    fontWeight: fuerte ? pw.FontWeight.bold : pw.FontWeight.normal,
    color: color ?? _tinta,
  );
}

pw.Widget _construirEncabezado(
  String nombreDelNegocio,
  Resumen resumen,
  DateTime generadoEn,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 10),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _tinta, width: 1.5)),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(nombreDelNegocio, style: _estilo(11, color: _tintaSuave)),
              pw.SizedBox(height: 2),
              pw.Text(
                _tituloDe(resumen.periodo),
                style: _estilo(22, fuerte: true),
              ),
            ],
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(_fechasDe(resumen), style: _estilo(12, fuerte: true)),
            pw.SizedBox(height: 2),
            pw.Text(
              'Generado el ${formatearFechaLarga(generadoEn).toLowerCase()}, '
              '${formatearHora(generadoEn)}',
              style: _estilo(9, color: _tintaSuave),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Una sola cuenta de libreta: vendido - gastos = utilidad.
pw.Widget _construirCuenta(Totales totales) {
  pw.Widget renglon(String concepto, String monto) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(concepto, style: _estilo(11)),
        pw.Text(monto, style: _estilo(12, fuerte: true)),
      ],
    );
  }

  return pw.Container(
    width: 260,
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _raya, width: 1.2),
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Column(
      children: [
        renglon(
          'Vendido (${totales.numeroDeVentas} ventas)',
          _dinero(totales.vendido),
        ),
        pw.SizedBox(height: 6),
        renglon('- Gastos', _dinero(totales.gastos)),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _tinta, width: 1.2)),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Utilidad', style: _estilo(12, fuerte: true)),
              pw.Text(
                _dinero(totales.utilidad),
                style: _estilo(22, fuerte: true),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _construirTitulo(String texto) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Text(texto, style: _estilo(13, fuerte: true)),
  );
}

/// Una tabla del reporte. La primera columna va a la izquierda y las demás
/// (los números) a la derecha. Si [ultimaFilaEsElTotal], esa fila va en
/// negritas.
pw.Widget _construirTabla({
  required List<String> encabezados,
  required List<List<String>> filas,
  bool ultimaFilaEsElTotal = false,
}) {
  return pw.TableHelper.fromTextArray(
    headers: encabezados,
    data: filas,
    border: null,
    headerStyle: _estilo(9, fuerte: true, color: _tintaSuave),
    headerDecoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _tinta, width: 1.2)),
    ),
    cellStyle: _estilo(10.5),
    cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
    rowDecoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _raya, width: 0.8)),
    ),
    cellAlignments: {
      for (var columna = 0; columna < encabezados.length; columna++)
        columna: columna == 0
            ? pw.Alignment.centerLeft
            : pw.Alignment.centerRight,
    },
    // `fila` cuenta también el encabezado: la última es `filas.length`.
    textStyleBuilder: (columna, dato, fila) {
      final esElTotal = ultimaFilaEsElTotal && fila == filas.length;
      return esElTotal ? _estilo(10.5, fuerte: true) : null;
    },
  );
}

pw.Widget _construirTablaPorDia(Resumen resumen) {
  final totales = resumen.totales;

  return _construirTabla(
    encabezados: ['Día', 'Ventas', 'Vendido', 'Gastos', 'Utilidad'],
    ultimaFilaEsElTotal: true,
    filas: [
      for (final dia in resumen.porDia)
        [
          formatearDiaSinMes(dia.dia),
          '${dia.numeroDeVentas}',
          _dinero(dia.vendido),
          // Un día sin gastos lleva un guion, no "$0".
          dia.gastos.esCero ? '-' : _dinero(dia.gastos),
          _dinero(dia.utilidad),
        ],
      [
        'Total',
        '${totales.numeroDeVentas}',
        _dinero(totales.vendido),
        _dinero(totales.gastos),
        _dinero(totales.utilidad),
      ],
    ],
  );
}

pw.Widget _construirTablaDeMasVendidos(List<ProductoVendido> productos) {
  if (productos.isEmpty) return pw.Text('Sin ventas.', style: _estilo(10.5));

  return _construirTabla(
    encabezados: ['Producto', 'Piezas', 'Vendido'],
    filas: [
      for (final producto in productos)
        [
          producto.nombreCompleto,
          '${producto.piezas}',
          _dinero(producto.vendido),
        ],
    ],
  );
}

pw.Widget _construirTablaDeGastos(List<GastoPorCategoria> gastos) {
  if (gastos.isEmpty) return pw.Text('Sin gastos.', style: _estilo(10.5));

  return _construirTabla(
    encabezados: ['Categoría', 'Gastado'],
    filas: [
      for (final gasto in gastos)
        [gasto.nombre ?? 'Sin categoría', _dinero(gasto.total)],
    ],
  );
}

pw.Widget _construirPie(pw.Context contexto) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 10),
    padding: const pw.EdgeInsets.only(top: 6),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: _raya, width: 0.8)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Hecho con Mi puesto · No incluye ventas canceladas · '
          'No es un comprobante fiscal',
          style: _estilo(8.5, color: _tintaSuave),
        ),
        pw.Text(
          'Página ${contexto.pageNumber} de ${contexto.pagesCount}',
          style: _estilo(8.5, color: _tintaSuave),
        ),
      ],
    ),
  );
}
