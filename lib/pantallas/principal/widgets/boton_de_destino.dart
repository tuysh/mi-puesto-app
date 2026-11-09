import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';
import 'package:mi_puesto/pantallas/principal/destino.dart';
import 'package:mi_puesto/pantallas/principal/widgets/icono_de_destino.dart';

/// Un botón del menú de navegación: icono arriba y nombre abajo.
/// El de la sección actual se distingue por la píldora rosa de su icono y
/// por el texto más oscuro.
class BotonDeDestino extends StatelessWidget {
  const BotonDeDestino({
    super.key,
    required this.destino,
    required this.estaElegido,
    required this.alTocar,
    this.ancho = 72,
    this.tamanoDePildora = const Size(60, 32),
    this.tamanoDeIcono = 24,
  });

  final Destino destino;
  final bool estaElegido;
  final VoidCallback alTocar;
  final double ancho;
  final Size tamanoDePildora;
  final double tamanoDeIcono;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      radio: 16,
      child: Container(
        width: ancho,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 3,
          children: [
            IconoDeDestino(
              icono: destino.icono,
              estaElegido: estaElegido,
              tamanoDePildora: tamanoDePildora,
              tamanoDeIcono: tamanoDeIcono,
            ),
            Text(
              destino.etiqueta,
              maxLines: 1,
              style: Tipografia.texto(
                13,
                peso: estaElegido ? 800 : 700,
                color: estaElegido ? Colores.tinta : Colores.tintaSuave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
