import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_filtro.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/categorias/grupo_de_categorias.dart';
import 'package:mi_puesto/pantallas/categorias/pantalla_de_categorias.dart';

/// En "Anotar gasto": la etiqueta "Categoría", el enlace para crear una
/// nueva y un botón por cada categoría de gasto. Tocar la elegida la quita
/// (un gasto puede no tener categoría).
///
/// Las categorías las crea la dueña; la aplicación no trae ninguna.
class SelectorDeCategoriaDeGasto extends StatefulWidget {
  const SelectorDeCategoriaDeGasto({
    super.key,
    required this.elegida,
    required this.alElegir,
  });

  /// `id` de la categoría elegida; `null` si ninguna.
  final String? elegida;

  final ValueChanged<String?> alElegir;

  @override
  State<SelectorDeCategoriaDeGasto> createState() =>
      _EstadoDeSelectorDeCategoriaDeGasto();
}

class _EstadoDeSelectorDeCategoriaDeGasto
    extends State<SelectorDeCategoriaDeGasto> {
  /// Cambia al volver de "Categorías", para que la lista se pida otra vez.
  int _version = 0;

  Future<void> _crearCategoria() async {
    await abrirPantalla(
      context,
      const PantallaDeCategorias(grupoInicial: GrupoDeCategorias.deGastos),
    );
    if (mounted) setState(() => _version++);
  }

  @override
  Widget build(BuildContext context) {
    final repositorio = Dependencias.de(context).conexiones.categoriasDeGastos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Categoría', style: Tipografia.texto(15, peso: 800)),
            ),
            BotonDeEnlace(texto: 'Nueva categoría', alTocar: _crearCategoria),
          ],
        ),
        CargadorDeFuturo<List<Categoria>>(
          key: ValueKey(_version),
          cargar: repositorio.obtenerCategorias,
          construir: (context, categorias) {
            if (categorias.isEmpty) {
              return const TextoDeAyuda(
                'Todavía no tienes categorías. Sirven para ver en qué se va '
                'el dinero.',
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final categoria in categorias)
                  BotonDeFiltro(
                    texto: categoria.nombre,
                    colores: categoria.colores,
                    estaElegido: categoria.id == widget.elegida,
                    alTocar: () => widget.alElegir(
                      // Tocar la que ya estaba elegida la quita.
                      categoria.id == widget.elegida ? null : categoria.id,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
