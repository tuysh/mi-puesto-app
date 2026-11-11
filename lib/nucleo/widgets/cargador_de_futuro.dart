import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/widgets/indicador_de_carga.dart';
import 'package:mi_puesto/nucleo/widgets/mensaje_de_error.dart';

/// Pide datos con [cargar] y, mientras llegan, muestra una rueda de carga.
/// Si la carga falla muestra un error con botón de reintentar, y cuando los
/// datos llegan dibuja lo que devuelva [construir].
///
/// ```dart
/// CargadorDeFuturo<VentasDelDia>(
///   cargar: () => repositorio.obtenerVentasDelDia(hoy()),
///   construir: (context, ventas) => Text('${ventas.cuantas}'),
/// )
/// ```
///
/// Para volver a pedir los datos (porque cambió la fecha, o porque se
/// guardó algo), dale otra `key`: Flutter lo crea de nuevo y vuelve a
/// llamar a [cargar].
class CargadorDeFuturo<Dato> extends StatefulWidget {
  const CargadorDeFuturo({
    super.key,
    required this.cargar,
    required this.construir,
  });

  final Future<Dato> Function() cargar;
  final Widget Function(BuildContext context, Dato dato) construir;

  @override
  State<CargadorDeFuturo<Dato>> createState() => _EstadoDeCargador<Dato>();
}

class _EstadoDeCargador<Dato> extends State<CargadorDeFuturo<Dato>> {
  late Future<Dato> _carga = widget.cargar();

  void _reintentar() {
    // Con llaves a propósito: `setState(() => _carga = …)` devolvería el
    // futuro, y Flutter no acepta que setState reciba uno.
    setState(() {
      _carga = widget.cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Dato>(
      future: _carga,
      builder: (context, resultado) {
        if (resultado.hasError) {
          // Deja el error en la consola para quien esté programando.
          debugPrint('No se pudo cargar: ${resultado.error}');

          return MensajeDeError(
            error: resultado.error,
            alReintentar: _reintentar,
          );
        }
        if (resultado.connectionState != ConnectionState.done) {
          return const IndicadorDeCarga();
        }
        return widget.construir(context, resultado.data as Dato);
      },
    );
  }
}
