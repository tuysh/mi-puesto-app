import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/pantallas/productos/vista_productos_tablet.dart';
import 'package:mi_puesto/pantallas/productos/vista_productos_telefono.dart';

/// Pantallas 5.2 y 6.2: los productos del negocio. Aquí se dan de alta, se
/// editan, se desactivan y se dice cuáles hay hoy.
class PantallaDeProductos extends StatelessWidget {
  const PantallaDeProductos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: esTablet(context)
            ? const VistaProductosTablet()
            : const VistaProductosTelefono(),
      ),
    );
  }
}
