/// Los "repositorios" son el contrato entre la aplicación y el backend.
///
/// Cada clase de este archivo solo DECLARA qué se le puede pedir al servidor;
/// no dice cómo se hace. Hay dos juegos de implementaciones:
///
/// - `datos/http`: las de verdad, que llaman a la API v1 del servidor.
/// - `datos/simulados`: las de mentira, que guardan todo en memoria. Sirven
///   para las pruebas y para trabajar sin servidor.
///
/// `datos/conexiones.dart` decide cuál juego se usa. Ninguna pantalla sabe
/// con cuál está hablando.
///
/// Cuando el servidor rechaza algo con una razón que se puede explicar, los
/// métodos lanzan un `ErrorDelServidor` con el mensaje para mostrar.
library;

import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/estado_de_acceso.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/modelos/puesto.dart';
import 'package:mi_puesto/datos/modelos/reporte.dart';
import 'package:mi_puesto/datos/modelos/resumen_del_dia.dart';
import 'package:mi_puesto/datos/modelos/vendedor.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';

/// La cuenta (correo y contraseña), los datos del puesto y el PIN.
///
/// La cuenta se pide una sola vez por dispositivo; después, para abrir la
/// aplicación basta el PIN. Por eso el servidor (o el dispositivo) debe
/// recordar la sesión hasta que se llame a [cerrarSesion].
///
/// Si algo falla por otra razón (por ejemplo, no hay internet), los métodos
/// deben lanzar una excepción: las pantallas la convierten en un aviso.
abstract interface class RepositorioDeSesion {
  /// Indica si este dispositivo ya tiene una sesión iniciada y si la cuenta
  /// ya tiene PIN. Se consulta al abrir la aplicación y después de entrar.
  Future<EstadoDeAcceso> consultarAcceso();

  /// Inicia sesión. Devuelve `false` si el correo o la contraseña no son
  /// correctos.
  Future<bool> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  /// Crea una cuenta y deja la sesión iniciada con ella. Si el servidor no
  /// la acepta (correo repetido, contraseña débil), lanza un
  /// `ErrorDelServidor` con la razón.
  Future<void> crearCuenta({
    required String correo,
    required String contrasena,
  });

  /// Olvida la sesión de este dispositivo.
  Future<void> cerrarSesion();

  /// El puesto de la cuenta que inició sesión.
  Future<Puesto> obtenerPuesto();

  /// Guarda el PIN del puesto (4 dígitos) para la cuenta que inició sesión.
  Future<void> guardarPin(String pin);

  /// Devuelve `true` si [pin] es el PIN correcto del puesto.
  Future<bool> validarPin(String pin);

  /// Registra a quién avisarle si el servidor deja de reconocer la sesión
  /// en medio del uso (por ejemplo, porque se cerró desde otro lado). La
  /// aplicación responde volviendo a "Inicia sesión".
  void avisarSiSePierdeLaSesion(void Function() aviso);
}

/// Las personas que venden.
abstract interface class RepositorioDeVendedores {
  Future<List<Vendedor>> obtenerVendedores();

  Future<Vendedor> agregarVendedor(String nombre);
}

/// Categorías y productos.
abstract interface class RepositorioDeCatalogo {
  Future<List<Categoria>> obtenerCategorias();

  /// Crea la categoría si es nueva o la actualiza si ya existía.
  /// Devuelve la categoría tal como quedó guardada (ya con `id`).
  Future<Categoria> guardarCategoria(Categoria categoria);

  /// Borra una categoría. La aplicación solo lo pide para categorías sin
  /// productos; conviene que el servidor también lo rechace si los tiene.
  Future<void> eliminarCategoria(String categoriaId);

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

/// Abrir la caja y cerrarla al final del día.
abstract interface class RepositorioDeCaja {
  /// La cuenta de la caja abierta, o `null` si no hay ninguna abierta.
  Future<CuentaDeCaja?> obtenerCuentaDeCaja();

  /// Abre la caja con [fondoInicial] (el dinero que hay para dar cambio).
  /// Las ventas en efectivo cuentan en la caja a partir de este momento.
  Future<CuentaDeCaja> abrirCaja(Dinero fondoInicial);

  /// Cierra la caja abierta con lo que se contó.
  Future<void> cerrarCaja(CierreDeCaja cierre);
}
