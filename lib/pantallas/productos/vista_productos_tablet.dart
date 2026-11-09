import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/controladores/controlador_de_catalogo.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/pantallas/productos/cambiar_visibilidad.dart';
import 'package:mi_puesto/pantallas/productos/widgets/encabezado_de_productos.dart';
import 'package:mi_puesto/pantallas/productos/widgets/formulario_de_producto.dart';
import 'package:mi_puesto/pantallas/productos/widgets/tabla_de_productos.dart';

/// "Productos" en tablet: la tabla a la izquierda y, a la derecha, el
/// formulario del producto elegido.
class VistaProductosTablet extends StatefulWidget {
  const VistaProductosTablet({super.key});

  @override
  State<VistaProductosTablet> createState() => _EstadoDeVistaProductosTablet();
}

class _EstadoDeVistaProductosTablet extends State<VistaProductosTablet> {
  /// `id` del producto elegido en la tabla.
  String? _idElegido;

  /// Producto en blanco que se está capturando tras tocar "Nuevo producto";
  /// `null` cuando se está editando uno que ya existe.
  Producto? _productoNuevo;

  /// El producto que muestra el formulario: el nuevo si se está creando
  /// uno; si no, el elegido en la tabla; y si no hay elegido, el primero.
  Producto? _productoEnEdicion(ControladorDeCatalogo catalogo) {
    return _productoNuevo ??
        catalogo.buscarProducto(_idElegido) ??
        catalogo.productos.firstOrNull;
  }

  void _elegir(Producto producto) {
    setState(() {
      _idElegido = producto.id;
      _productoNuevo = null;
    });
  }

  void _empezarProductoNuevo() {
    final categorias = Dependencias.de(context).catalogo.categorias;
    if (categorias.isEmpty) return;

    setState(() {
      _productoNuevo = Producto.nuevo(categoriaId: categorias.first.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalogo = Dependencias.de(context).catalogo;

    return ListenableBuilder(
      listenable: catalogo,
      builder: (context, _) {
        final enEdicion = _productoEnEdicion(catalogo);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 14,
                  children: [
                    EncabezadoDeProductos(
                      productos: catalogo.productos,
                      alCrear: _empezarProductoNuevo,
                    ),
                    Expanded(
                      child: TablaDeProductos(
                        productos: catalogo.productos,
                        idElegido: enEdicion?.id,
                        alElegir: _elegir,
                        alCambiarVisibilidad: (producto, aLaVenta) {
                          cambiarVisibilidad(
                            context,
                            producto,
                            aLaVenta: aLaVenta,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 360,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Colores.superficie,
                border: Border(left: BorderSide(color: Colores.borde)),
              ),
              child: enEdicion == null
                  ? null
                  : FormularioDeProducto(
                      // La clave hace que el formulario empiece de cero al
                      // cambiar de producto.
                      key: ValueKey(enEdicion.id),
                      producto: enEdicion,
                      alGuardar: _elegir,
                    ),
            ),
          ],
        );
      },
    );
  }
}
