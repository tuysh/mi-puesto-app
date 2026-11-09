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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titulo, style: Tipografia.titulo(19, peso: 700)),
              ?alLadoDelTitulo,
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}
