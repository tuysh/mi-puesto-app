import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/controladores/estado_de_carga.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/fechas.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/widgets/indicador_de_carga.dart';
import 'package:mi_puesto/nucleo/widgets/mensaje_de_error.dart';
import 'package:mi_puesto/pantallas/caja/vista_de_abrir_caja.dart';
import 'package:mi_puesto/pantallas/caja/vista_de_caja_de_ayer.dart';
import 'package:mi_puesto/pantallas/caja/vista_de_caja_sin_abrir.dart';
import 'package:mi_puesto/pantallas/vender/elegir_tamanos.dart';
import 'package:mi_puesto/pantallas/vender/vista_vender_tablet.dart';
import 'package:mi_puesto/pantallas/vender/vista_vender_telefono.dart';

/// Pantalla 2.3: se tocan los productos que lleva el cliente para armar
/// el pedido.
///
/// Sin caja abierta nadie puede vender. Por eso, antes de mostrar los
/// productos, revisa la caja:
/// - cerrada y está la dueña → el formulario para abrirla;
/// - cerrada y está alguien que solo vende → el aviso de que pida abrirla;
/// - abierta desde un día anterior y está la dueña → le pide cerrarla.
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

  /// `true` si la dueña prefirió seguir vendiendo en la caja de ayer en
  /// vez de cerrarla ahora.
  bool _sigueConLaCajaDeAyer = false;

  void _elegirCategoria(String? categoriaId) {
    setState(() => _categoriaId = categoriaId);
  }

  void _buscar(String texto) {
    setState(() => _busqueda = texto);
  }

  void _tocarProducto(Producto producto) {
    final dependencias = Dependencias.de(context);

    // Empezar otro pedido quita el aviso de la venta anterior.
    dependencias.ventas.cerrarAviso();

    if (producto.tieneTamanos) {
      elegirTamanos(
        context,
        producto: producto,
        colores: dependencias.catalogo.coloresDe(producto.categoriaId),
      );
    } else {
      dependencias.pedido.agregar(producto);
    }
  }

  void _cargarTodo() {
    final dependencias = Dependencias.de(context);
    dependencias.caja.cargar();
    dependencias.catalogo.cargar();
  }

  @override
  Widget build(BuildContext context) {
    final dependencias = Dependencias.de(context);
    final caja = dependencias.caja;
    final catalogo = dependencias.catalogo;

    return ListenableBuilder(
      listenable: Listenable.merge([caja, catalogo]),
      builder: (context, _) {
        final error = caja.error ?? catalogo.error;
        if (error != null) {
          return MensajeDeError(error: error, alReintentar: _cargarTodo);
        }

        final sigueCargando =
            caja.estado == EstadoDeCarga.cargando ||
            catalogo.estado == EstadoDeCarga.cargando;
        if (sigueCargando) return const IndicadorDeCarga();

        return _construirSegunLaCaja();
      },
    );
  }

  Widget _construirSegunLaCaja() {
    final dependencias = Dependencias.de(context);
    final esDuena = dependencias.sesion.esDuena;
    final caja = dependencias.caja.caja;

    if (caja == null) {
      return esDuena ? const VistaDeAbrirCaja() : const VistaDeCajaSinAbrir();
    }

    final esDeAyer = caja.esDeUnDiaAnteriorA(hoy());
    if (esDeAyer && esDuena && !_sigueConLaCajaDeAyer) {
      return VistaDeCajaDeAyer(
        alSeguirVendiendo: () => setState(() => _sigueConLaCajaDeAyer = true),
      );
    }

    return _construirProductos();
  }

  Widget _construirProductos() {
    final catalogo = Dependencias.de(context).catalogo;
    final productos = catalogo.productosParaVender(
      categoriaId: _categoriaId,
      busqueda: _busqueda,
    );

    if (esTablet(context)) {
      return VistaVenderTablet(
        categorias: catalogo.categorias,
        categoriaElegida: _categoriaId,
        alElegirCategoria: _elegirCategoria,
        productos: productos,
        alTocarProducto: _tocarProducto,
        alBuscar: _buscar,
      );
    }

    return VistaVenderTelefono(
      categorias: catalogo.categorias,
      categoriaElegida: _categoriaId,
      alElegirCategoria: _elegirCategoria,
      productos: productos,
      alTocarProducto: _tocarProducto,
    );
  }
}
