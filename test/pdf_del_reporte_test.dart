import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/pantallas/reportes/crear_pdf_del_reporte.dart';

/// El PDF del reporte lo arma la aplicación. Aquí solo se revisa que salga
/// un PDF de verdad con cualquier periodo; cómo se ve se revisa a ojo.
void main() {
  Resumen resumenDe(Periodo periodo, {required int dias}) {
    final desde = DateTime(2026, 11, 2);

    return Resumen(
      periodo: periodo,
      desde: desde,
      hasta: desde.add(Duration(days: dias - 1)),
      totales: const Totales(
        vendido: Dinero.pesos(6820),
        numeroDeVentas: 127,
        enEfectivo: Dinero.pesos(5000),
        conTarjeta: Dinero.pesos(1820),
        gastos: Dinero.pesos(3910),
        utilidad: Dinero.pesos(2910),
      ),
      porDia: [
        for (var dia = 0; dia < dias; dia++)
          DiaDeResumen(
            dia: desde.add(Duration(days: dia)),
            numeroDeVentas: 15,
            vendido: const Dinero.pesos(820),
            // Un día sin gastos y otro con pérdida.
            gastos: dia == 0 ? Dinero.cero : const Dinero.pesos(2030),
            utilidad: dia == 0
                ? const Dinero.pesos(820)
                : const Dinero.pesos(-1210),
          ),
      ],
      masVendidos: const [
        ProductoVendido(
          nombreDelProducto: 'Horchata',
          nombreDelTamano: 'Grande',
          categoriaId: '3',
          representacion: Representacion.emoji,
          emoji: '🥛',
          letras: 'Ho',
          imagenUrl: '',
          piezas: 30,
          vendido: Dinero.pesos(750),
        ),
      ],
      gastosPorCategoria: const [
        GastoPorCategoria(
          nombre: 'Ingredientes',
          color: 0,
          total: Dinero.pesos(3070),
        ),
        GastoPorCategoria(nombre: null, color: null, total: Dinero.pesos(840)),
      ],
    );
  }

  /// Los archivos PDF empiezan con las letras `%PDF`.
  bool esUnPdf(List<int> bytes) =>
      ascii.decode(bytes.take(4).toList()) == '%PDF';

  test('el reporte de la semana sale como PDF', () async {
    final resumen = resumenDe(Periodo.semana, dias: 7);

    final pdf = await crearPdfDelReporte(
      nombreDelNegocio: 'Puesto Doña Mari',
      resumen: resumen,
      generadoEn: DateTime(2026, 11, 8, 20, 42),
    );

    expect(esUnPdf(pdf), isTrue);
    expect(nombreDelArchivo(resumen), 'reporte-semana-2026-11-02.pdf');
  });

  test(
    'el de un mes, con más días de los que caben en una hoja, también',
    () async {
      final pdf = await crearPdfDelReporte(
        nombreDelNegocio: 'Puesto Doña Mari',
        resumen: resumenDe(Periodo.mes, dias: 62),
        generadoEn: DateTime(2026, 11, 30, 9),
      );

      expect(esUnPdf(pdf), isTrue);
    },
  );

  test('un periodo sin movimientos no truena', () async {
    final pdf = await crearPdfDelReporte(
      nombreDelNegocio: '',
      resumen: Resumen(
        periodo: Periodo.dia,
        desde: DateTime(2026, 11, 2),
        hasta: DateTime(2026, 11, 2),
        totales: Totales.enCeros,
      ),
      generadoEn: DateTime(2026, 11, 2),
    );

    expect(esUnPdf(pdf), isTrue);
  });
}
