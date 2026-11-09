import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';
import 'package:mi_puesto/pantallas/vender/widgets/aviso_de_ultima_venta.dart';
import 'package:mi_puesto/pantallas/vender/widgets/buscador_de_productos.dart';
import 'package:mi_puesto/pantallas/vender/widgets/cuadricula_de_productos.dart';
import 'package:mi_puesto/pantallas/vender/widgets/filtro_de_categorias.dart';
import 'package:mi_puesto/pantallas/vender/widgets/panel_de_pedido.dart';

/// "Vender" en tablet: los productos a la izquierda y, siempre visible a la
/// derecha, el pedido con el cobro.
class VistaVenderTablet extends StatelessWidget {
  const VistaVenderTablet({
    super.key,
    required this.categorias,
    required this.categoriaElegida,
    required this.alElegirCategoria,
    required this.productos,
    required this.alTocarProducto,
    required this.alBuscar,
  });

  final List<Categoria> categorias;
  final String? categoriaElegida;
  final ValueChanged<String?> alElegirCategoria;
  final List<Producto> productos;
  final ValueChanged<Producto> alTocarProducto;
  final ValueChanged<String> alBuscar;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _construirProductos()),
        const PanelDePedido(),
      ],
    );
  }

  Widget _construirProductos() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: EncabezadoDePantalla(
                  titulo: 'Vender',
                  tamanoDeTitulo: 34,
                ),
              ),
              SizedBox(
                width: 260,
                child: BuscadorDeProductos(alBuscar: alBuscar),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FiltroDeCategorias(
            categorias: categorias,
            elegida: categoriaElegida,
            alElegir: alElegirCategoria,
          ),
          const SizedBox(height: 6),
          Expanded(
            // Stack encima: el aviso de venta FLOTA sobre los productos.
            child: Stack(
              children: [
                CuadriculaDeProductos(
                  productos: productos,
                  rejilla: rejillaDeTablet,
                  alTocarProducto: alTocarProducto,
                  relleno: const EdgeInsets.fromLTRB(0, 8, 8, 16),
                ),
                const Positioned(
                  left: 0,
                  right: 8,
                  bottom: 16,
                  child: AvisoDeUltimaVenta(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
