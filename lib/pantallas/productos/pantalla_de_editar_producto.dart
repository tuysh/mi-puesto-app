import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/pantallas/productos/widgets/formulario_de_producto.dart';

/// Pantalla 5.3 (teléfono): el formulario de un producto a pantalla
/// completa. Al guardar o desactivar, vuelve a la lista.
class PantallaDeEditarProducto extends StatelessWidget {
  const PantallaDeEditarProducto({super.key, required this.producto});

  /// El producto a editar, o uno en blanco (`Producto.nuevo`) para crear.
  final Producto producto;

  @override
  Widget build(BuildContext context) {
    return MarcoDePantalla(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          EncabezadoConVolver(
            titulo: producto.esNuevo ? 'Nuevo producto' : 'Editar producto',
          ),
          Expanded(
            child: FormularioDeProducto(
              producto: producto,
              alGuardar: (_) => cerrarPantalla(context),
              alDesactivar: () => cerrarPantalla(context),
            ),
          ),
        ],
      ),
    );
  }
}
