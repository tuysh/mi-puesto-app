import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Una tecla redonda del teclado del PIN.
class TeclaDePin extends StatelessWidget {
  const TeclaDePin({
    super.key,
    required this.child,
    required this.alTocar,
    required this.etiqueta,
    this.esSecundaria = false,
  });

  /// Lo que se dibuja dentro de la tecla: un número o un icono.
  final Widget child;

  final VoidCallback alTocar;

  /// Texto para lectores de pantalla.
  final String etiqueta;

  /// Las teclas secundarias (borrar) son grises y sin sombra.
  final bool esSecundaria;

  static const tamano = 78.0;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      etiqueta: etiqueta,
      radio: Radios.pildora,
      decoracion: BoxDecoration(
        color: esSecundaria ? Colores.superficieHundida : Colores.superficie,
        boxShadow: esSecundaria ? null : Sombras.dura(alto: 3),
      ),
      child: SizedBox(
        width: tamano,
        height: tamano,
        child: Center(child: child),
      ),
    );
  }
}
