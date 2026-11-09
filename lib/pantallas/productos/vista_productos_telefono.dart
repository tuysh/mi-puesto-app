import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/pantallas/productos/cambiar_visibilidad.dart';
import 'package:mi_puesto/pantallas/productos/pantalla_de_editar_producto.dart';
import 'package:mi_puesto/pantallas/productos/widgets/encabezado_de_productos.dart';
import 'package:mi_puesto/pantallas/productos/widgets/tabla_de_productos.dart';

/// "Productos" en teléfono: solo la tabla (con menos columnas). Al tocar un
/// producto, el formulario se abre en una pantalla aparte.
class VistaProductosTelefono extends StatelessWidget {
  const VistaProductosTelefono({super.key});

  void _editar(BuildContext context, Producto producto) {
    abrirPantalla(context, PantallaDeEditarProducto(producto: producto));
  }

  void _crear(BuildContext context) {
    final categorias = Dependencias.de(context).catalogo.categorias;
    if (categorias.isEmpty) return;

    _editar(context, Producto.nuevo(categoriaId: categorias.first.id));
  }

  @override
  Widget build(BuildContext context) {
    final catalogo = Dependencias.de(context).catalogo;

    return ListenableBuilder(
      listenable: catalogo,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              EncabezadoDeProductos(
                productos: catalogo.productos,
                alCrear: () => _crear(context),
              ),
              Expanded(
                child: TablaDeProductos(
                  productos: catalogo.productos,
                  esCompacta: true,
                  alElegir: (producto) => _editar(context, producto),
                  alCambiarVisibilidad: (producto, aLaVenta) {
                    cambiarVisibilidad(context, producto, aLaVenta: aLaVenta);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
