import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/pantallas/productos/pantalla_de_editar_categoria.dart';
import 'package:mi_puesto/pantallas/productos/widgets/fila_de_categoria.dart';

/// La lista de categorías del puesto. Desde aquí se crean categorías
/// nuevas y se editan las que ya existen.
class PantallaDeCategorias extends StatelessWidget {
  const PantallaDeCategorias({super.key});

  void _editar(BuildContext context, Categoria categoria) {
    abrirPantalla(context, PantallaDeEditarCategoria(categoria: categoria));
  }

  @override
  Widget build(BuildContext context) {
    final catalogo = Dependencias.de(context).catalogo;

    return Scaffold(
      body: SafeArea(
        child: AnchoMaximo(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            // Se redibuja cuando se guarda una categoría.
            child: ListenableBuilder(
              listenable: catalogo,
              builder: (context, _) {
                return ColumnaConPie(
                  espacio: 10,
                  pie: BotonPrincipal(
                    texto: 'Nueva categoría',
                    icono: Icons.add_rounded,
                    alTocar: () => _editar(context, const Categoria.nueva()),
                  ),
                  children: [
                    const EncabezadoConVolver(titulo: 'Categorías'),
                    for (final categoria in catalogo.categorias)
                      FilaDeCategoria(
                        categoria: categoria,
                        cantidadDeProductos: catalogo.cantidadDeProductosEn(
                          categoria,
                        ),
                        alTocar: () => _editar(context, categoria),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
