import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/pantallas/productos/widgets/formulario_de_producto.dart';

/// En teléfono: el formulario de un producto a pantalla completa.
class PantallaDeEditarProducto extends StatelessWidget {
  const PantallaDeEditarProducto({super.key, required this.producto});

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              EncabezadoConVolver(
                titulo: producto.esNuevo ? 'Nuevo producto' : 'Editar producto',
              ),
              Expanded(
                child: FormularioDeProducto(
                  producto: producto,
                  alGuardar: (_) => cerrarPantalla(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
