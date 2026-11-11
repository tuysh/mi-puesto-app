import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/cuenta.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/gasto.dart';
import 'package:mi_puesto/datos/modelos/negocio.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/datos/simulados/datos_de_ejemplo.dart';
import 'package:mi_puesto/datos/simulados/espera_simulada.dart';
import 'package:mi_puesto/nucleo/fechas.dart';

/// Un servidor de mentira: guarda en memoria todo lo que guardaría el de
/// verdad, y se pierde al cerrar la aplicación.
///
/// Los repositorios simulados comparten uno solo. Así lo que hace uno (por
/// ejemplo, registrar una venta) lo ven los demás (la caja, el resumen).
///
/// Aquí viven los datos y las reglas que usan varios repositorios; lo
/// propio de cada tema está en su `Repositorio…Simulado`.
class ServidorSimulado {
  /// Con [conSesionIniciada] arranca como si la cuenta de ejemplo ya
  /// hubiera entrado antes en este dispositivo. Con [conCajaAbierta] en
  /// `false` la caja de ejemplo empieza cerrada.
  ServidorSimulado({
    bool conSesionIniciada = false,
    bool conCajaAbierta = true,
  }) {
    _ponerNegocioDeEjemplo(conCajaAbierta: conCajaAbierta);
    haySesion = conSesionIniciada;
  }

  /// Las cuentas que existen: la contraseña de cada correo.
  final contrasenas = <String, String>{correoDeEjemplo: contrasenaDeEjemplo};

  bool haySesion = false;
  Negocio negocio = negocioDeEjemplo;

  /// Todas las personas, también las desactivadas.
  List<Perfil> perfiles = [];

  /// El PIN de cada persona, por su `id`.
  Map<String, String> pines = {};

  /// El `id` de quien está dentro; `null` si nadie ha escrito su PIN.
  String? perfilActivoId;

  List<Categoria> categorias = [];
  List<Categoria> categoriasDeGastos = [];

  /// Solo los productos activos.
  List<Producto> productos = [];

  /// Todas las ventas, de la más vieja a la más nueva.
  List<Venta> ventas = [];

  /// A qué caja pertenece cada venta, por el `id` de la venta.
  Map<String, String> cajaDeCadaVenta = {};

  List<Gasto> gastos = [];

  /// La caja abierta; `null` si está cerrada. Sus montos se calculan al
  /// pedirla (ver `RepositorioDeCajaSimulado`).
  Caja? cajaAbierta;

  /// Las cajas ya cerradas, de la más vieja a la más nueva.
  List<Caja> cajasCerradas = [];

  int _ultimoId = 100;

  /// Un `id` que nadie más tiene.
  String idNuevo() => '${++_ultimoId}';

  Perfil? get perfilActivo {
    for (final perfil in perfiles) {
      if (perfil.id == perfilActivoId) return perfil;
    }
    return null;
  }

  /// La respuesta de `/cuenta`: el negocio, las personas activas y quién
  /// está dentro.
  Cuenta get cuenta {
    return Cuenta(
      negocio: negocio,
      perfiles: [
        for (final perfil in perfiles)
          if (perfil.activo) perfil,
      ],
      perfilActivo: perfilActivo,
    );
  }

  /// Lo que hace todo repositorio antes de responder: tarda un poco y
  /// revisa que haya sesión.
  Future<void> atender() async {
    await esperaSimulada();
    if (!haySesion) {
      throw const ErrorDelServidor(
        'La sesión se cerró. Vuelve a iniciar sesión.',
        codigoHttp: 401,
      );
    }
  }

  /// Igual que [atender], y además exige que alguien haya escrito su PIN.
  /// Devuelve a esa persona.
  Future<Perfil> atenderAAlguien() async {
    await atender();

    final perfil = perfilActivo;
    if (perfil == null) {
      throw const ErrorDelServidor(
        'Escribe tu PIN para continuar.',
        codigoHttp: 403,
        codigo: CodigosDeError.sinPerfil,
      );
    }
    return perfil;
  }

  /// Igual que [atenderAAlguien], y además exige que sea la dueña.
  Future<Perfil> atenderALaDuena() async {
    final perfil = await atenderAAlguien();
    if (!perfil.esDueno) {
      throw const ErrorDelServidor(
        'Solo la dueña puede hacer esto.',
        codigoHttp: 403,
        codigo: 'solo_dueno',
      );
    }
    return perfil;
  }

  /// La caja abierta, o el error `sin_caja` si no hay ninguna.
  Caja exigirCajaAbierta() {
    final caja = cajaAbierta;
    if (caja == null) {
      throw const ErrorDelServidor(
        'La caja está cerrada. Ábrela para poder registrar.',
        codigoHttp: 409,
        codigo: CodigosDeError.sinCaja,
      );
    }
    return caja;
  }

  /// Las ventas de una caja que sí cuentan (las canceladas no).
  List<Venta> ventasQueCuentanDe(String cajaId) {
    return [
      for (final venta in ventas)
        if (cajaDeCadaVenta[venta.id] == cajaId && !venta.estaCancelada) venta,
    ];
  }

  /// El pastel que le toca a lo siguiente que se cree en [lista]: los
  /// colores se reparten en orden y, al acabarse, se repiten.
  int siguienteColor(List<Object> lista) => lista.length % 5;

  /// Deja un negocio recién creado: sin personas, productos ni ventas.
  void ponerNegocioNuevo({required String nombre, required String correo}) {
    negocio = Negocio(id: idNuevo(), nombre: nombre, correo: correo);
    perfiles = [];
    pines = {};
    perfilActivoId = null;
    categorias = [];
    categoriasDeGastos = [];
    productos = [];
    ventas = [];
    cajaDeCadaVenta = {};
    gastos = [];
    cajaAbierta = null;
    cajasCerradas = [];
  }

  /// Deja el negocio de ejemplo: el del diseño, con la caja abierta y un
  /// par de gastos de hoy.
  void ponerNegocioDeEjemplo() => _ponerNegocioDeEjemplo(conCajaAbierta: true);

  void _ponerNegocioDeEjemplo({required bool conCajaAbierta}) {
    final hoy = soloElDia(DateTime.now());

    negocio = negocioDeEjemplo;
    perfiles = [...perfilesDeEjemplo];
    pines = {...pinesDeEjemplo};
    perfilActivoId = null;
    categorias = [...categoriasDeEjemplo];
    categoriasDeGastos = [...categoriasDeGastosDeEjemplo];
    productos = [...productosDeEjemplo];
    ventas = [];
    cajaDeCadaVenta = {};
    cajasCerradas = [];
    cajaAbierta = conCajaAbierta
        ? Caja(
            id: idNuevo(),
            fecha: hoy,
            abierta: true,
            fondoInicial: const Dinero.pesos(500),
          )
        : null;
    gastos = [
      Gasto(
        id: idNuevo(),
        concepto: 'Fresas y crema',
        monto: const Dinero.pesos(420),
        fecha: hoy,
        categoriaId: categoriasDeGastosDeEjemplo[0].id,
        // Solo se puede pagar de la caja si hay una abierta.
        deCaja: conCajaAbierta,
      ),
      Gasto(
        id: idNuevo(),
        concepto: 'Cuota de la semana',
        monto: const Dinero.pesos(250),
        fecha: hoy,
        categoriaId: categoriasDeGastosDeEjemplo[3].id,
        deCaja: false,
      ),
    ];
  }
}
