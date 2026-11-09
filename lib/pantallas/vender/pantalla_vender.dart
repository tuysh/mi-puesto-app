import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/controladores/controlador_de_catalogo.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/widgets/indicador_de_carga.dart';
import 'package:mi_puesto/nucleo/widgets/mensaje_de_error.dart';
import 'package:mi_puesto/pantallas/vender/vista_vender_tablet.dart';
import 'package:mi_puesto/pantallas/vender/vista_vender_telefono.dart';

/// Pantalla 3: se tocan los productos que lleva el cliente para armar
/// el pedido.
///
/// Esta clase guarda los filtros (categoría y búsqueda) y decide qué vista
/// mostrar; el dibujo está en [VistaVenderTelefono] y [VistaVenderTablet].
class PantallaVender extends StatefulWidget {
  const PantallaVender({super.key});

  @override
  State<PantallaVender> createState() => _EstadoDePantallaVender();
}

class _EstadoDePantallaVender extends State<PantallaVender> {
  /// La categoría elegida en el filtro; `null` significa "Todo".
  String? _categoriaId;

  String _busqueda = '';

  void _elegirCategoria(String? categoriaId) {
    setState(() => _categoriaId = categoriaId);
  }

  void _buscar(String texto) {
    setState(() => _busqueda = texto);
  }

  void _agregarAlPedido(Producto producto) {
    final dependencias = Dependencias.de(context);

    // Empezar otro pedido quita el aviso de la venta anterior.
    dependencias.ventas.cerrarAviso();
    dependencias.pedido.agregar(producto);
  }

  @override
  Widget build(BuildContext context) {
    final catalogo = Dependencias.de(context).catalogo;

    return ListenableBuilder(
      listenable: catalogo,
      builder: (context, _) {
        return switch (catalogo.estado) {
          EstadoDeCarga.cargando => const IndicadorDeCarga(),
          EstadoDeCarga.conError => MensajeDeError(
            alReintentar: catalogo.cargar,
          ),
          EstadoDeCarga.listo => _construirVista(catalogo),
        };
      },
    );
  }

  Widget _construirVista(ControladorDeCatalogo catalogo) {
    final productos = catalogo.productosALaVenta(
      categoriaId: _categoriaId,
      busqueda: _busqueda,
    );

    if (esTablet(context)) {
      return VistaVenderTablet(
        categorias: catalogo.categorias,
        categoriaElegida: _categoriaId,
        alElegirCategoria: _elegirCategoria,
        productos: productos,
        alTocarProducto: _agregarAlPedido,
        alBuscar: _buscar,
      );
    }

    return VistaVenderTelefono(
      categorias: catalogo.categorias,
      categoriaElegida: _categoriaId,
      alElegirCategoria: _elegirCategoria,
      productos: productos,
      alTocarProducto: _agregarAlPedido,
    );
  }
}
