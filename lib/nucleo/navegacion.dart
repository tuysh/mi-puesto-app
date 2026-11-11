import 'package:flutter/material.dart';

/// Abre [pantalla] encima de la actual (se puede volver atrás).
Future<void> abrirPantalla(BuildContext context, Widget pantalla) {
  return Navigator.of(context).push(_ruta(pantalla));
}

/// Cambia la pantalla actual por [pantalla] (no se puede volver atrás).
void reemplazarPantalla(BuildContext context, Widget pantalla) {
  Navigator.of(context).pushReplacement(_ruta(pantalla));
}

/// Cierra todas las pantallas abiertas y deja solo [pantalla].
///
/// Usa el navegador de hasta arriba (`rootNavigator`): en tablet la sección
/// "Más" tiene su propio navegador, y sin esto solo se cambiaría esa parte.
void reemplazarTodasLasPantallas(BuildContext context, Widget pantalla) {
  Navigator.of(
    context,
    rootNavigator: true,
  ).pushAndRemoveUntil(_ruta(pantalla), (ruta) => false);
}

/// Cierra la pantalla, hoja o diálogo actual.
void cerrarPantalla(BuildContext context) {
  Navigator.of(context).pop();
}

MaterialPageRoute<void> _ruta(Widget pantalla) {
  return MaterialPageRoute(builder: (context) => pantalla);
}
