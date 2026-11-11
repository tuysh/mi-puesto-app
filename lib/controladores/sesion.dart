import 'package:flutter/foundation.dart';
import 'package:mi_puesto/datos/modelos/cuenta.dart';
import 'package:mi_puesto/datos/modelos/estado_de_acceso.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Recuerda de qué negocio es el dispositivo y quién lo está usando, y se
/// encarga de entrar y salir.
class Sesion extends ChangeNotifier {
  Sesion(this._repositorio) {
    _repositorio.avisarSiSePierdeLaSesion(_olvidarTodo);
    _repositorio.avisarSiNoHayNadieDentro(_olvidarQuienEstabaDentro);
  }

  final RepositorioDeSesion _repositorio;

  /// Se llama cuando el servidor deja de reconocer la sesión en medio del
  /// uso. La aplicación lo aprovecha para volver a "Inicia sesión".
  VoidCallback? alPerderLaSesion;

  /// Se llama cuando el servidor dice que ya no hay nadie dentro. La
  /// aplicación lo aprovecha para volver a "¿Quién vende hoy?".
  VoidCallback? alQuedarSinNadieDentro;

  Cuenta? _cuenta;

  /// Nombre del negocio, o vacío mientras no hay sesión.
  String get nombreDelNegocio => _cuenta?.negocio.nombre ?? '';

  /// Quien escribió su PIN; `null` hasta que alguien entra.
  Perfil? get perfil => _cuenta?.perfilActivo;

  /// `true` si quien está dentro es la dueña: puede todo. Quien solo vende
  /// ve nada más "Vender" y sus ventas.
  bool get esDuena => perfil?.esDueno ?? false;

  /// Las personas activas: las de "¿Quién vende hoy?".
  List<Perfil> get perfiles => _cuenta?.perfiles ?? const [];

  /// La dueña del negocio; `null` mientras no hay sesión.
  Perfil? get duena {
    for (final perfil in perfiles) {
      if (perfil.esDueno) return perfil;
    }
    return null;
  }

  /// El nombre de la persona [perfilId], para decir quién hizo una venta.
  String nombreDe(String perfilId) {
    for (final perfil in perfiles) {
      if (perfil.id == perfilId) return perfil.nombre;
    }
    // Las personas desactivadas ya no vienen en la lista.
    return 'Alguien que ya no vende';
  }

  /// Averigua en qué paso va este dispositivo: sin sesión, sin dueña, sin
  /// nadie dentro o ya dentro.
  Future<EstadoDeAcceso> consultarAcceso() async {
    _recordar(await _repositorio.consultarCuenta());
    return estadoDeAccesoDe(_cuenta);
  }

  /// Vuelve a pedir la cuenta. Sirve después de agregar o cambiar personas.
  Future<void> recargar() => consultarAcceso();

  /// Inicia sesión con una cuenta que ya existe.
  ///
  /// Devuelve [EstadoDeAcceso.sinSesion] si el correo o la contraseña no
  /// son correctos; si lo son, devuelve el paso que sigue.
  Future<EstadoDeAcceso> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    final cuenta = await _repositorio.iniciarSesion(
      correo: correo,
      contrasena: contrasena,
    );
    if (cuenta == null) return EstadoDeAcceso.sinSesion;

    _recordar(cuenta);
    return estadoDeAccesoDe(cuenta);
  }

  /// Crea la cuenta de un negocio nuevo y deja la sesión iniciada con ella.
  /// Si el servidor no la acepta, lanza un `ErrorDelServidor` con la razón.
  Future<void> crearCuenta({
    required String nombreDelNegocio,
    required String correo,
    required String contrasena,
  }) async {
    final cuenta = await _repositorio.crearCuenta(
      nombreDelNegocio: nombreDelNegocio,
      correo: correo,
      contrasena: contrasena,
    );
    _recordar(cuenta);
  }

  /// Último paso del registro: crea a la dueña y la deja dentro.
  Future<void> crearDuena({required String nombre, required String pin}) async {
    _recordar(await _repositorio.crearDuena(nombre: nombre, pin: pin));
  }

  /// Entra como [perfil] con su PIN. Devuelve `false` si el PIN no es
  /// correcto.
  Future<bool> entrar(Perfil perfil, String pin) async {
    final cuenta = await _repositorio.entrarComoPerfil(
      perfilId: perfil.id,
      pin: pin,
    );
    if (cuenta == null) return false;

    _recordar(cuenta);
    return true;
  }

  /// Deja el dispositivo sin nadie dentro, para que entre otra persona.
  Future<void> cambiarDePersona() async {
    await _repositorio.salirDelPerfil();
    _olvidarQuienEstabaDentro(avisar: false);
  }

  /// Sale de la cuenta y olvida el negocio y a quien estaba dentro.
  Future<void> cerrarSesion() async {
    await _repositorio.cerrarSesion();
    _recordar(null);
  }

  void _recordar(Cuenta? cuenta) {
    _cuenta = cuenta;
    notifyListeners();
  }

  void _olvidarTodo() {
    _recordar(null);
    alPerderLaSesion?.call();
  }

  void _olvidarQuienEstabaDentro({bool avisar = true}) {
    final cuenta = _cuenta;
    if (cuenta == null) return;

    _recordar(
      Cuenta(
        negocio: cuenta.negocio,
        perfiles: cuenta.perfiles,
        perfilActivo: null,
      ),
    );
    if (avisar) alQuedarSinNadieDentro?.call();
  }
}
