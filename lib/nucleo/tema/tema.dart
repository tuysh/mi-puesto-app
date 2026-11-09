import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Tema general de Material. Casi todo el aspecto vive en los widgets de
/// `nucleo/widgets`; aquí solo se ajustan los valores por omisión.
ThemeData crearTema() {
  final esquema = ColorScheme.fromSeed(
    seedColor: Colores.acento,
    surface: Colores.fondo,
    onSurface: Colores.tinta,
  );

  return ThemeData(
    colorScheme: esquema,
    scaffoldBackgroundColor: Colores.fondo,
    fontFamily: Tipografia.familiaDeTexto,
    dialogTheme: const DialogThemeData(backgroundColor: Colores.superficie),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colores.tinta,
      contentTextStyle: Tipografia.texto(15, color: Colores.superficie),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
