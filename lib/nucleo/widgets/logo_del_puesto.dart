import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';

/// El emblema de la aplicación: un puestito blanco sobre fondo oscuro.
class LogoDelPuesto extends StatelessWidget {
  const LogoDelPuesto({
    super.key,
    this.tamano = 72,
    this.altoDeSombra = 4,
    this.icono = Icons.storefront_outlined,
  });

  /// Lado del cuadro.
  final double tamano;

  /// Grosor de la franja rosa de abajo.
  final double altoDeSombra;

  /// El dibujo de adentro. Normalmente es el puestito; la pantalla de crear
  /// el PIN lo cambia por un candado.
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: Colores.tinta,
        borderRadius: BorderRadius.circular(tamano / 3),
        boxShadow: Sombras.dura(color: Colores.acento, alto: altoDeSombra),
      ),
      child: Icon(icono, color: Colores.fondo, size: tamano / 2),
    );
  }
}
