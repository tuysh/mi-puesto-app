import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/pantallas/productos/eliminar_categoria.dart';
import 'package:mi_puesto/pantallas/productos/widgets/formulario_de_categoria.dart';

/// El formulario de una categoría (nueva o existente) a pantalla completa.
class PantallaDeEditarCategoria extends StatelessWidget {
  const PantallaDeEditarCategoria({super.key, required this.categoria});

  final Categoria categoria;

  Future<void> _eliminar(BuildContext context) async {
    final seElimino = await eliminarCategoria(context, categoria);
    if (seElimino && context.mounted) cerrarPantalla(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnchoMaximo(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                EncabezadoConVolver(
                  titulo: categoria.esNueva
                      ? 'Nueva categoría'
                      : 'Editar categoría',
                ),
                Expanded(
                  child: FormularioDeCategoria(
                    categoria: categoria,
                    alGuardar: (_) => cerrarPantalla(context),
                    // Una categoría nueva todavía no existe: no hay nada
                    // que eliminar.
                    alEliminar: categoria.esNueva
                        ? null
                        : () => _eliminar(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
