import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';
import 'package:mi_puesto/nucleo/widgets/pastilla.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_de_seccion.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';

/// La tarjeta "Gastos por categoría" de "Reportes": un renglón por
/// categoría con lo gastado, y el enlace para ver todos los gastos.
class SeccionDeGastosPorCategoria extends StatelessWidget {
  const SeccionDeGastosPorCategoria({
    super.key,
    required this.gastos,
    required this.alVerTodos,
  });

  final List<GastoPorCategoria> gastos;
  final VoidCallback alVerTodos;

  @override
  Widget build(BuildContext context) {
    return TarjetaDeSeccion(
      titulo: 'Gastos por categoría',
      children: [
        if (gastos.isEmpty)
          const TextoDeAyuda('No hay gastos en este periodo.'),
        for (final gasto in gastos)
          Row(
            spacing: 12,
            children: [
              // La pastilla va pegada a la izquierda y el monto a la
              // derecha, alineado con los demás.
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Pastilla(
                    alto: 30,
                    // Los gastos sin categoría salen juntos, en gris.
                    texto: gasto.nombre ?? 'Sin categoría',
                    colores: gasto.color == null
                        ? Colores.sinCategoria
                        : Pasteles.paraIndice(gasto.color!),
                  ),
                ),
              ),
              Cifra(formatearDinero(gasto.total), tamano: 18),
            ],
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: BotonDeEnlace(
            texto: 'Ver todos los gastos',
            alTocar: alVerTodos,
          ),
        ),
      ],
    );
  }
}
