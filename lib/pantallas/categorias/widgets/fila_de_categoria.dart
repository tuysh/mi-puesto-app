import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/pastilla.dart';

/// Un renglón de la lista de categorías: su nombre en una pastilla de su
/// color, cuántas cosas tiene y los botones para renombrarla y eliminarla.
class FilaDeCategoria extends StatelessWidget {
  const FilaDeCategoria({
    super.key,
    required this.categoria,
    required this.textoDeUsos,
    required this.alRenombrar,
    required this.alEliminar,
  });

  final Categoria categoria;

  /// Cuántas cosas tiene, ya como texto: "5 productos".
  final String textoDeUsos;

  final VoidCallback alRenombrar;
  final VoidCallback alEliminar;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.only(left: 14, right: 6),
      child: Row(
        spacing: 10,
        children: [
          // Un tope de ancho para que un nombre muy largo no empuje los
          // botones fuera del renglón.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Pastilla(
              texto: categoria.nombre,
              colores: categoria.colores,
              tamanoDeTexto: 15,
              rellenoLateral: 14,
            ),
          ),
          Expanded(
            child: Text(
              textoDeUsos,
              maxLines: 1,
              style: Tipografia.texto(14, color: Colores.tintaSuave),
            ),
          ),
          IconButton(
            tooltip: 'Cambiar nombre de ${categoria.nombre}',
            onPressed: alRenombrar,
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: Colores.tinta,
          ),
          IconButton(
            tooltip: 'Eliminar ${categoria.nombre}',
            onPressed: alEliminar,
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: Colores.tinta,
          ),
        ],
      ),
    );
  }
}
