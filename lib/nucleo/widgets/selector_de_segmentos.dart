import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Varios botones juntos en una misma barra, de los que solo uno está
/// elegido: "Día · Semana · Mes" o "Emoji · Letras · Foto".
class SelectorDeSegmentos<Opcion> extends StatelessWidget {
  const SelectorDeSegmentos({
    super.key,
    required this.opciones,
    required this.elegida,
    required this.alElegir,
  });

  /// Cada opción con el texto de su botón, en el orden en que se muestran.
  final Map<Opcion, String> opciones;

  final Opcion elegida;
  final ValueChanged<Opcion> alElegir;

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
          for (final MapEntry(key: opcion, value: texto) in opciones.entries)
            Expanded(
              child: _Segmento(
                texto: texto,
                estaElegido: opcion == elegida,
                alTocar: () => alElegir(opcion),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segmento extends StatelessWidget {
  const _Segmento({
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
