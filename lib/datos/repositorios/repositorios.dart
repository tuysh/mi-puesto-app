/// Los "repositorios" son el contrato entre la aplicación y el backend.
///
/// Cada clase de este archivo solo DECLARA qué se le puede pedir al servidor;
/// no dice cómo se hace. Hoy las únicas implementaciones son las simuladas
/// (carpeta `datos/simulados`), que guardan todo en memoria.
///
/// Para conectar el backend real:
///   1. Crea una clase por repositorio que haga las llamadas al servidor,
///      por ejemplo `class RepositorioDeVentasHttp implements
///      RepositorioDeVentas`.
///   2. Úsalas en `datos/conexiones.dart`.
/// Ninguna pantalla necesita cambiar.
library;

import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/modelos/puesto.dart';
import 'package:mi_puesto/datos/modelos/reporte.dart';
import 'package:mi_puesto/datos/modelos/resumen_del_dia.dart';
import 'package:mi_puesto/datos/modelos/vendedor.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';

/// Datos del puesto y entrada con PIN.
abstract interface class RepositorioDeSesion {
  Future<Puesto> obtenerPuesto();

  /// Devuelve `true` si [pin] es el PIN correcto del puesto.
  Future<bool> validarPin(String pin);
}

/// Las personas que venden.
abstract interface class RepositorioDeVendedores {
  Future<List<Vendedor>> obtenerVendedores();

  Future<Vendedor> agregarVendedor(String nombre);
}

/// Categorías y productos.
abstract interface class RepositorioDeCatalogo {
  Future<List<Categoria>> obtenerCategorias();

  /// Devuelve todos los productos, incluidos los ocultos.
  Future<List<Producto>> obtenerProductos();

  /// Crea el producto si es nuevo o lo actualiza si ya existía.
  /// Devuelve el producto tal como quedó guardado (ya con `id`).
  Future<Producto> guardarProducto(Producto producto);
}

/// Registro de ventas.
abstract interface class RepositorioDeVentas {
  Future<Venta> registrarVenta({
    required List<LineaDePedido> lineas,
    required Dinero pagoCon,
    required Vendedor vendedor,
  });

  /// Cancela una venta registrada por error.
  Future<void> anularVenta(String ventaId);
}

/// Números para las pantallas "Hoy" y "Reportes".
abstract interface class RepositorioDeReportes {
  Future<ResumenDelDia> obtenerResumenDeHoy();

  Future<Reporte> obtenerReporte(Periodo periodo);
}

/// Cierre de caja al final del día.
abstract interface class RepositorioDeCaja {
  Future<CuentaDeCaja> obtenerCuentaDeCaja();

  Future<void> cerrarCaja(CierreDeCaja cierre);
}
