import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/controladores/controlador_de_catalogo.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/pantallas/productos/cambiar_disponibilidad.dart';
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

  /// `true` mientras se captura un producto nuevo (tras tocar "Nuevo
  /// producto"); `false` cuando se edita uno que ya existe.
  bool _creandoUnoNuevo = false;

  /// El producto que muestra el formulario: uno en blanco si se está
  /// creando; si no, el elegido en la tabla; y si no hay elegido, el
  /// primero.
  Producto? _productoEnEdicion(ControladorDeCatalogo catalogo) {
    if (_creandoUnoNuevo) return const Producto.nuevo();

    return catalogo.buscarProducto(_idElegido) ??
        catalogo.productos.firstOrNull;
  }

  void _elegir(Producto producto) {
    setState(() {
      _idElegido = producto.id;
      _creandoUnoNuevo = false;
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
                      cuantosProductos: catalogo.productos.length,
                      cuantosHayHoy: catalogo.cuantosHayHoy,
                      alCrear: () => setState(() => _creandoUnoNuevo = true),
                    ),
                    Expanded(
                      child: TablaDeProductos(
                        productos: catalogo.productos,
                        idElegido: enEdicion?.id,
                        alElegir: _elegir,
                        alCambiarSiHayHoy: (producto, hayHoy) {
                          cambiarDisponibilidad(
                            context,
                            producto,
                            hayHoy: hayHoy,
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
                      conTitulo: true,
                      alGuardar: _elegir,
                      // Al desactivarlo sale de la tabla: el formulario
                      // pasa solo al primero de los que quedan.
                      alDesactivar: () => setState(() => _idElegido = null),
                    ),
            ),
          ],
        );
      },
    );
  }
}
