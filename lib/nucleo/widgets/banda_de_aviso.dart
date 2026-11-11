import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Franja de color con un aviso corto: "Caja abierta · abriste con $500"
/// (verde) o "La caja de ayer sigue abierta" (ámbar), con una explicación
/// opcional debajo.
class BandaDeAviso extends StatelessWidget {
  const BandaDeAviso({
    super.key,
    required this.titulo,
    this.explicacion,
    this.colores = Colores.exito,
  });

  final String titulo;
  final String? explicacion;
  final ParDeColores colores;

  @override
  Widget build(BuildContext context) {
    final explicacion = this.explicacion;

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: colores.fondo,
        borderRadius: BorderRadius.circular(Radios.tarjeta),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(
            titulo,
            style: Tipografia.texto(
              explicacion == null ? 15 : 16,
              peso: 800,
              color: colores.tinta,
            ),
          ),
          if (explicacion != null)
            Text(
              explicacion,
              style: Tipografia.texto(14, color: colores.tinta, altura: 1.35),
            ),
        ],
      ),
    );
  }
}
