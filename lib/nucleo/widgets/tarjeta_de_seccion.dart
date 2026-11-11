import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_de_contorno.dart';

/// Tarjeta con un título arriba y una lista de elementos debajo.
class TarjetaDeSeccion extends StatelessWidget {
  const TarjetaDeSeccion({
    super.key,
    required this.titulo,
    required this.children,
    this.alLadoDelTitulo,
  });

  final String titulo;
  final List<Widget> children;

  /// Widget opcional que se coloca a la derecha del título.
  final Widget? alLadoDelTitulo;

  @override
  Widget build(BuildContext context) {
    return TarjetaDeContorno(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Row(
            spacing: 8,
            children: [
              // El título ocupa lo que deja libre lo de la derecha. Si en
              // una pantalla angosta no cabe, FittedBox lo encoge en vez
              // de que el renglón se desborde.
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(titulo, style: Tipografia.titulo(19, peso: 700)),
                ),
              ),
              ?alLadoDelTitulo,
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}
