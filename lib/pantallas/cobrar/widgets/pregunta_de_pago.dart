import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';

/// El renglón encima de los billetes. Antes de elegir uno, pregunta; una vez
/// elegido, dice "Pagó con:" y ofrece volver a "Fue exacto".
class PreguntaDePago extends StatelessWidget {
  const PreguntaDePago({
    super.key,
    required this.hayBilleteElegido,
    required this.alDecirQueFueExacto,
  });

  final bool hayBilleteElegido;
  final VoidCallback alDecirQueFueExacto;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      // Alto fijo para que la pantalla no brinque al aparecer el enlace.
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hayBilleteElegido
                  ? 'Pagó con:'
                  : '¿Pagó con más? Toca con cuánto',
              style: Tipografia.texto(15, peso: 800),
            ),
          ),
          if (hayBilleteElegido)
            BotonDeEnlace(texto: 'Fue exacto', alTocar: alDecirQueFueExacto),
        ],
      ),
    );
  }
}
