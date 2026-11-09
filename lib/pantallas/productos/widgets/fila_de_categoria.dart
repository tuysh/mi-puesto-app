import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';
import 'package:mi_puesto/nucleo/widgets/cuadro_de_emoji.dart';

/// Una categoría en la lista: su emoji, su nombre y cuántos productos
/// tiene. Al tocarla se abre para editarla.
class FilaDeCategoria extends StatelessWidget {
  const FilaDeCategoria({
    super.key,
    required this.categoria,
    required this.cantidadDeProductos,
    required this.alTocar,
  });

  final Categoria categoria;
  final int cantidadDeProductos;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final palabra = cantidadDeProductos == 1 ? 'producto' : 'productos';

    return CajaTocable(
      alTocar: alTocar,
      radio: Radios.tarjeta,
      decoracion: BoxDecoration(
        color: Colores.superficie,
        border: Border.all(color: Colores.borde, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          spacing: 14,
          children: [
            CuadroDeEmoji(
              emoji: categoria.emoji,
              fondo: categoria.colores.fondo,
              tamano: 48,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    categoria.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Tipografia.texto(17, peso: 800),
                  ),
                  Text(
                    '$cantidadDeProductos $palabra',
                    style: Tipografia.texto(14, color: Colores.tintaSuave),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colores.tintaSuave,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
