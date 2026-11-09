import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/pantallas/vender/widgets/aviso_de_ultima_venta.dart';
import 'package:mi_puesto/pantallas/vender/widgets/barra_de_pedido.dart';
import 'package:mi_puesto/pantallas/vender/widgets/cuadricula_de_productos.dart';
import 'package:mi_puesto/pantallas/vender/widgets/encabezado_de_vender.dart';
import 'package:mi_puesto/pantallas/vender/widgets/filtro_de_categorias.dart';
import 'package:mi_puesto/pantallas/vender/widgets/pista_de_pedido_vacio.dart';

/// "Vender" en teléfono: de arriba a abajo, el encabezado, el filtro, los
/// productos en tres columnas y, al fondo, el resumen del pedido.
class VistaVenderTelefono extends StatelessWidget {
  const VistaVenderTelefono({
    super.key,
    required this.categorias,
    required this.categoriaElegida,
    required this.alElegirCategoria,
    required this.productos,
    required this.alTocarProducto,
  });

  final List<Categoria> categorias;
  final String? categoriaElegida;
  final ValueChanged<String?> alElegirCategoria;
  final List<Producto> productos;
  final ValueChanged<Producto> alTocarProducto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 22, 18, 10),
          child: EncabezadoDeVender(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
          child: FiltroDeCategorias(
            categorias: categorias,
            elegida: categoriaElegida,
            alElegir: alElegirCategoria,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: PistaDePedidoVacio(),
        ),
        Expanded(
          // Stack encima: el aviso de venta FLOTA sobre los productos, que
          // se siguen viendo alrededor y por debajo de él.
          child: Stack(
            children: [
              CuadriculaDeProductos(
                productos: productos,
                rejilla: rejillaDeTelefono,
                alTocarProducto: alTocarProducto,
                relleno: const EdgeInsets.fromLTRB(18, 8, 18, 16),
              ),
              const Positioned(
                left: 18,
                right: 18,
                bottom: 12,
                child: AvisoDeUltimaVenta(),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: BarraDePedido(),
        ),
      ],
    );
  }
}
