import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/widgets/dialogo_de_texto.dart';

/// Abre un diálogo para escribir con cuánto pagó el cliente cuando no fue
/// con uno de los billetes comunes.
///
/// Devuelve `null` si se canceló o si el monto no alcanza para [total].
Future<Dinero?> pedirOtroMonto(
  BuildContext context, {
  required Dinero total,
}) async {
  final texto = await pedirTexto(
    context,
    titulo: '¿Con cuánto pagó?',
    prefijo: '\$ ',
    esNumero: true,
  );
  if (texto == null || !context.mounted) return null;

  final monto = leerDinero(texto);
  if (monto == null) {
    mostrarAviso(context, 'Escribe solo el número, por ejemplo 150');
    return null;
  }
  if (monto < total) {
    mostrarAviso(context, 'No alcanza: el total es ${formatearDinero(total)}');
    return null;
  }
  return monto;
}
