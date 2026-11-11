import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/widgets/dialogo_de_texto.dart';

/// Cuántos números tiene un PIN.
const largoDelPin = 4;

/// `true` si [texto] sirve como PIN: exactamente 4 números.
bool esUnPinValido(String texto) {
  return RegExp('^[0-9]{$largoDelPin}\$').hasMatch(texto);
}

/// Abre un diálogo para escribir el PIN nuevo de [nombre]. Devuelve el PIN,
/// o `null` si se canceló o lo escrito no son 4 números.
Future<String?> pedirPinNuevo(
  BuildContext context, {
  required String nombre,
}) async {
  final texto = await pedirTexto(
    context,
    titulo: nombre.isEmpty ? 'PIN nuevo' : 'PIN nuevo de $nombre',
    sugerencia: '4 números',
    esNumero: true,
    maximoDeLetras: largoDelPin,
  );
  if (texto == null || !context.mounted) return null;

  if (!esUnPinValido(texto)) {
    mostrarAviso(context, 'El PIN son 4 números');
    return null;
  }
  return texto;
}
