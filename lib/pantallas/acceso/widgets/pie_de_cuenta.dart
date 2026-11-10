import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';

/// Lo que va hasta abajo en las pantallas de cuenta: una pregunta y el
/// botón que lleva a la otra pantalla ("¿Ya tienes cuenta?" → "Iniciar
/// sesión", y al revés).
class PieDeCuenta extends StatelessWidget {
  const PieDeCuenta({
    super.key,
    required this.pregunta,
    required this.textoDelBoton,
    required this.alTocar,
  });

  final String pregunta;
  final String textoDelBoton;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Text(
          pregunta,
          textAlign: TextAlign.center,
          style: Tipografia.texto(15, color: Colores.tintaSuave),
        ),
        BotonDeContorno(texto: textoDelBoton, alTocar: alTocar),
      ],
    );
  }
}
