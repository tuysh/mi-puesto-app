import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/reporte.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Los tres botones juntos para elegir Día, Semana o Mes.
class SelectorDePeriodo extends StatelessWidget {
  const SelectorDePeriodo({
    super.key,
    required this.elegido,
    required this.alElegir,
  });

  final Periodo elegido;
  final ValueChanged<Periodo> alElegir;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colores.superficieHundida,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        spacing: 4,
        children: [
          for (final periodo in Periodo.values)
            Expanded(
              child: _BotonDePeriodo(
                texto: periodo.etiqueta,
                estaElegido: periodo == elegido,
                alTocar: () => alElegir(periodo),
              ),
            ),
        ],
      ),
    );
  }
}

class _BotonDePeriodo extends StatelessWidget {
  const _BotonDePeriodo({
    required this.texto,
    required this.estaElegido,
    required this.alTocar,
  });

  final String texto;
  final bool estaElegido;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      radio: 14,
      decoracion: BoxDecoration(
        color: estaElegido ? Colores.superficie : null,
        boxShadow: estaElegido ? Sombras.dura(alto: 2) : null,
      ),
      child: SizedBox(
        height: 44,
        child: Center(
          child: Text(
            texto,
            style: Tipografia.texto(
              15,
              peso: 800,
              color: estaElegido ? Colores.tinta : Colores.tintaSuave,
            ),
          ),
        ),
      ),
    );
  }
}
