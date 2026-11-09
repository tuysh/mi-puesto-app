import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/pantallas/productos/vista_productos_tablet.dart';
import 'package:mi_puesto/pantallas/productos/vista_productos_telefono.dart';

/// La sección "Productos": se dan de alta, se editan y se ocultan los
/// productos del puesto.
class PantallaDeProductos extends StatelessWidget {
  const PantallaDeProductos({super.key});

  @override
  Widget build(BuildContext context) {
    return esTablet(context)
        ? const VistaProductosTablet()
        : const VistaProductosTelefono();
  }
}
