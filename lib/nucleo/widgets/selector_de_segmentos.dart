import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Varios botones juntos en una misma barra, de los que solo uno está
/// elegido: "Día · Semana · Mes" o "Efectivo · Tarjeta".
class SelectorDeSegmentos<Opcion> extends StatelessWidget {
  const SelectorDeSegmentos({
    super.key,
    required this.opciones,
    required this.elegida,
    required this.alElegir,
    this.alto = 44,
    this.tamanoDeTexto = 15,
    this.ocuparTodoElAncho = true,
  });

  /// La variante un poco más alta, para las preguntas de un formulario:
  /// "¿Cómo pagó?", "¿Cómo se vende?".
  const SelectorDeSegmentos.grande({
    super.key,
    required this.opciones,
    required this.elegida,
    required this.alElegir,
  }) : alto = 48,
       tamanoDeTexto = 16,
       ocuparTodoElAncho = true;

  /// Cada opción con el texto de su botón, en el orden en que se muestran.
  final Map<Opcion, String> opciones;

  final Opcion elegida;
  final ValueChanged<Opcion> alElegir;

  /// Alto de cada botón.
  final double alto;

  final double tamanoDeTexto;

  /// Con `true` los botones se reparten todo el ancho. Con `false` cada
  /// uno mide lo que mide su texto (sirve junto a un título).
  final bool ocuparTodoElAncho;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colores.superficieHundida,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: ocuparTodoElAncho ? MainAxisSize.max : MainAxisSize.min,
        spacing: 4,
        children: [
          for (final MapEntry(key: opcion, value: texto) in opciones.entries)
            if (ocuparTodoElAncho)
              Expanded(child: _construirSegmento(opcion, texto))
            else
              _construirSegmento(opcion, texto),
        ],
      ),
    );
  }

  Widget _construirSegmento(Opcion opcion, String texto) {
    return _Segmento(
      texto: texto,
      estaElegido: opcion == elegida,
      alTocar: () => alElegir(opcion),
      alto: alto,
      tamanoDeTexto: tamanoDeTexto,
    );
  }
}

class _Segmento extends StatelessWidget {
  const _Segmento({
    required this.texto,
    required this.estaElegido,
    required this.alTocar,
    required this.alto,
    required this.tamanoDeTexto,
  });

  final String texto;
  final bool estaElegido;
  final VoidCallback alTocar;
  final double alto;
  final double tamanoDeTexto;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      radio: 14,
      decoracion: BoxDecoration(
        color: estaElegido ? Colores.superficie : null,
        boxShadow: estaElegido ? Sombras.dura(alto: 2) : null,
      ),
      child: Container(
        height: alto,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          widthFactor: 1,
          child: Text(
            texto,
            maxLines: 1,
            style: Tipografia.texto(
              tamanoDeTexto,
              peso: 800,
              color: estaElegido ? Colores.tinta : Colores.tintaSuave,
            ),
          ),
        ),
      ),
    );
  }
}
