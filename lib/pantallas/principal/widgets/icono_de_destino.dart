import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';

/// El icono de un botón del menú.
///
/// El de la sección actual va en blanco dentro de una píldora rosa con
/// sombra dura; los demás van en gris, sin fondo. Los dos ocupan el mismo
/// espacio, así el menú no "brinca" al cambiar de sección.
class IconoDeDestino extends StatelessWidget {
  const IconoDeDestino({
    super.key,
    required this.icono,
    required this.estaElegido,
    required this.tamanoDePildora,
    required this.tamanoDeIcono,
  });

  final IconData icono;
  final bool estaElegido;
  final Size tamanoDePildora;
  final double tamanoDeIcono;

  static const _altoDeSombra = 3.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Deja sitio a la sombra, que sobresale por abajo de la píldora.
      padding: const EdgeInsets.only(bottom: _altoDeSombra),
      child: Container(
        width: tamanoDePildora.width,
        height: tamanoDePildora.height,
        decoration: estaElegido
            ? BoxDecoration(
                color: Colores.acento,
                borderRadius: BorderRadius.circular(Radios.pildora),
                boxShadow: Sombras.dura(
                  color: Colores.tinta,
                  alto: _altoDeSombra,
                ),
              )
            : null,
        child: Icon(
          icono,
          size: tamanoDeIcono,
          color: estaElegido ? Colores.superficie : Colores.tintaSuave,
        ),
      ),
    );
  }
}
