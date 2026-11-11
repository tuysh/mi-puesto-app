/// Los "repositorios" son el contrato entre la aplicación y el backend.
///
/// Cada clase de este archivo solo DECLARA qué se le puede pedir al servidor;
/// no dice cómo se hace. Hay dos juegos de implementaciones:
///
/// - `datos/http`: las de verdad, que llaman a la API v2 del servidor.
/// - `datos/simulados`: las de mentira, que guardan todo en memoria. Sirven
///   para las pruebas y para trabajar sin servidor.
///
/// `datos/conexiones.dart` decide cuál juego se usa. Ninguna pantalla sabe
/// con cuál está hablando.
///
/// Cuando el servidor rechaza algo con una razón que se puede explicar, los
/// métodos lanzan un `ErrorDelServidor` con el mensaje para mostrar. Sin
/// internet lanzan un `ErrorDeConexion`.
library;

import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/catalogo.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/cuenta.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/foto_nueva.dart';
import 'package:mi_puesto/datos/modelos/gasto.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';

/// La cuenta del negocio (correo y contraseña) y quién usa el dispositivo.
///
/// La cuenta se pide una sola vez por dispositivo. Después, cada persona
/// entra escribiendo su PIN, y el servidor recuerda quién es hasta que
/// alguien más entre o se llame a [salirDelPerfil].
abstract interface class RepositorioDeSesion {
  /// Lo que el servidor sabe de la sesión de este dispositivo, o `null` si
  /// nadie ha iniciado sesión. Se consulta al abrir la aplicación.
  Future<Cuenta?> consultarCuenta();

  /// Inicia sesión. Devuelve `null` si el correo o la contraseña no son
  /// correctos.
  Future<Cuenta?> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  /// Crea la cuenta de un negocio nuevo y deja la sesión iniciada con ella.
  /// Todavía no tiene dueña: falta [crearDuena].
  Future<Cuenta> crearCuenta({
    required String nombreDelNegocio,
    required String correo,
    required String contrasena,
  });

  /// Último paso del registro: crea el perfil de la dueña con su nombre y
  /// su PIN, y la deja dentro.
  Future<Cuenta> crearDuena({required String nombre, required String pin});

  /// Entra como la persona [perfilId] con su PIN. Devuelve `null` si el
  /// PIN no es correcto.
  Future<Cuenta?> entrarComoPerfil({
    required String perfilId,
    required String pin,
  });

  /// Deja el dispositivo sin nadie dentro: toca "¿Quién vende hoy?".
  Future<void> salirDelPerfil();

  /// Olvida la sesión de este dispositivo.
  Future<void> cerrarSesion();

  /// Registra a quién avisarle si el servidor deja de reconocer la sesión
  /// en medio del uso. La aplicación responde volviendo a "Inicia sesión".
  void avisarSiSePierdeLaSesion(void Function() aviso);

  /// Registra a quién avisarle si el servidor dice que ya no hay nadie
  /// dentro (por ejemplo, porque desactivaron a esa persona). La aplicación
  /// responde volviendo a "¿Quién vende hoy?".
  void avisarSiNoHayNadieDentro(void Function() aviso);
}

/// Las personas del negocio. Solo la dueña puede usarlo.
abstract interface class RepositorioDePerfiles {
  /// Todas las personas, también las desactivadas.
  Future<List<Perfil>> obtenerPerfiles();

  /// Agrega a alguien que vende.
  Future<Perfil> crearPerfil({required String nombre, required String pin});

  /// Cambia lo que se indique de una persona; lo demás queda igual.
  /// Con [activo] en `false` se desactiva.
  Future<Perfil> cambiarPerfil(
    String perfilId, {
    String? nombre,
    String? pin,
    bool? activo,
  });
}

/// Los productos y lo que se pinta al vender.
abstract interface class RepositorioDeCatalogo {
  /// Las categorías y los productos activos. Lo puede pedir cualquiera.
  Future<Catalogo> obtenerCatalogo();

  /// Crea el producto si es nuevo o lo actualiza si ya existía.
  /// Devuelve el producto tal como quedó guardado (ya con `id`).
  ///
  /// Guarda el emoji y las letras, pero NO la foto: esa va aparte, con
  /// [subirFotoDeProducto] y [quitarFotoDeProducto].
  Future<Producto> guardarProducto(Producto producto);

  /// Prende o apaga "Hay hoy".
  Future<Producto> cambiarDisponibilidad(String productoId, bool disponible);

  /// Saca el producto de "Vender". Sus ventas no cambian.
  Future<void> desactivarProducto(String productoId);

  /// Sube la foto de un producto que ya existe (o reemplaza la que tenía).
  /// Devuelve el producto con la dirección de la foto nueva.
  Future<Producto> subirFotoDeProducto(String productoId, FotoNueva foto);

  /// Le quita la foto a un producto; vuelve a verse con su emoji o sus
  /// letras. Devuelve el producto ya sin foto.
  Future<Producto> quitarFotoDeProducto(String productoId);
}

/// Las categorías. Hay dos repositorios con este mismo contrato: el de las
/// categorías de productos y el de las de gastos.
abstract interface class RepositorioDeCategorias {
  /// Todas, cada una con cuántos productos (o gastos) tiene.
  Future<List<Categoria>> obtenerCategorias();

  /// El servidor le reparte el color que sigue.
  Future<Categoria> crearCategoria(String nombre);

  Future<Categoria> renombrarCategoria(String categoriaId, String nombre);

  /// Sus productos (o gastos) quedan sin categoría.
  Future<void> eliminarCategoria(String categoriaId);
}

/// Registro y consulta de ventas.
abstract interface class RepositorioDeVentas {
  /// Registra una venta a nombre de quien está dentro. Los precios no se
  /// mandan: los pone el servidor.
  ///
  /// [montoRecibido] es con cuánto pagó el cliente; `null` significa pago
  /// exacto. Con tarjeta se ignora.
  Future<Venta> registrarVenta({
    required List<LineaPorCobrar> lineas,
    required MetodoDePago metodoDePago,
    Dinero? montoRecibido,
    String nota = '',
  });

  /// Las ventas de [fecha]. La dueña ve las de todos; quien vende, solo
  /// las suyas.
  Future<VentasDelDia> obtenerVentasDelDia(DateTime fecha);

  /// Una venta con su historial y con `sePuedeCambiar`.
  Future<Venta> obtenerVenta(String ventaId);

  /// Cambia lo que se indique de una venta. [lineas] es el pedido completo,
  /// no un cambio parcial. Solo la dueña, y solo con la caja abierta.
  Future<Venta> editarVenta(
    String ventaId, {
    List<LineaPorCobrar>? lineas,
    MetodoDePago? metodoDePago,
    String? nota,
  });

  /// La venta no se borra: deja de contar en la caja y en los reportes.
  Future<Venta> cancelarVenta(String ventaId);
}

/// Abrir la caja, cerrarla y consultar los cierres anteriores.
abstract interface class RepositorioDeCaja {
  /// La caja abierta, o `null` si no hay ninguna. Sin caja no se vende.
  Future<Caja?> obtenerCajaAbierta();

  /// Abre la caja con [fondoInicial] (el dinero que hay para dar cambio).
  Future<Caja> abrirCaja(Dinero fondoInicial);

  /// Cierra la caja abierta con lo que se contó. Es definitivo.
  Future<Caja> cerrarCaja({required Dinero contado, required String nota});

  /// Los cierres anteriores, del más nuevo al más viejo, por páginas.
  /// Para la página que sigue se manda en [antes] el `siguiente` de la
  /// página anterior.
  Future<PaginaDeCierres> obtenerCierres({String? antes});

  /// Un cierre completo.
  Future<Caja> obtenerCierre(String cajaId);
}

/// Los gastos del negocio. Solo la dueña.
abstract interface class RepositorioDeGastos {
  /// Los gastos entre [desde] y [hasta] (los dos días entran). Con
  /// [categoriaId] solo los de esa categoría.
  Future<GastosDelPeriodo> obtenerGastos({
    required DateTime desde,
    required DateTime hasta,
    String? categoriaId,
  });

  /// Crea el gasto si es nuevo o lo actualiza si ya existía.
  Future<Gasto> guardarGasto(Gasto gasto);

  Future<void> eliminarGasto(String gastoId);
}

/// Los números de "Hoy", "Reportes" y el PDF. Solo la dueña.
abstract interface class RepositorioDeResumen {
  /// El resumen del [periodo] que contiene a [fecha], con las [secciones]
  /// pedidas. [orden] acomoda "Lo más vendido" y [cuantosProductos] dice
  /// cuántos trae.
  Future<Resumen> obtenerResumen({
    required Periodo periodo,
    required DateTime fecha,
    required Set<SeccionDeResumen> secciones,
    OrdenDeProductos orden = OrdenDeProductos.cantidad,
    int cuantosProductos = 5,
  });
}
