import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/modelos/estado_de_acceso.dart';
import 'package:mi_puesto/datos/modelos/puesto.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/datos_de_ejemplo.dart';
import 'package:mi_puesto/datos/simulados/espera_simulada.dart';

/// Cuentas de mentira: viven en memoria y se pierden al cerrar.
/// Siempre existe la cuenta de ejemplo (ver `datos_de_ejemplo.dart`).
class RepositorioDeSesionSimulado implements RepositorioDeSesion {
  /// Con [conSesionIniciada] la aplicación arranca como si la cuenta de
  /// ejemplo ya hubiera entrado antes: abre directo en el PIN.
  RepositorioDeSesionSimulado({bool conSesionIniciada = false}) {
    if (conSesionIniciada) _correoActual = correoDeEjemplo;
  }

  /// Las cuentas que existen, por correo.
  final _cuentas = <String, _Cuenta>{
    correoDeEjemplo: _Cuenta(
      contrasena: contrasenaDeEjemplo,
      pin: pinDeEjemplo,
    ),
  };

  /// El correo de la cuenta que inició sesión; `null` si no hay sesión.
  String? _correoActual;

  _Cuenta? get _cuentaActual => _cuentas[_correoActual];

  @override
  Future<EstadoDeAcceso> consultarAcceso() async {
    await esperaSimulada();

    final cuenta = _cuentaActual;
    if (cuenta == null) return EstadoDeAcceso.sinSesion;
    if (cuenta.pin == null) return EstadoDeAcceso.faltaElPin;
    return EstadoDeAcceso.listo;
  }

  @override
  Future<bool> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    await esperaSimulada();

    final cuenta = _cuentas[_normalizar(correo)];
    if (cuenta == null || cuenta.contrasena != contrasena) return false;

    _correoActual = _normalizar(correo);
    return true;
  }

  @override
  Future<void> crearCuenta({
    required String correo,
    required String contrasena,
  }) async {
    await esperaSimulada();

    final correoNormalizado = _normalizar(correo);
    if (_cuentas.containsKey(correoNormalizado)) {
      throw const ErrorDelServidor('Ya hay una cuenta con ese correo.');
    }

    _cuentas[correoNormalizado] = _Cuenta(contrasena: contrasena);
    _correoActual = correoNormalizado;
  }

  @override
  Future<void> cerrarSesion() async {
    await esperaSimulada();
    _correoActual = null;
  }

  @override
  Future<Puesto> obtenerPuesto() async {
    await esperaSimulada();
    return puestoDeEjemplo;
  }

  @override
  Future<void> guardarPin(String pin) async {
    await esperaSimulada();
    _cuentaConSesion().pin = pin;
  }

  @override
  Future<bool> validarPin(String pin) async {
    await esperaSimulada();
    return _cuentaConSesion().pin == pin;
  }

  /// La sesión simulada nunca se pierde sola: no hay nada que avisar.
  @override
  void avisarSiSePierdeLaSesion(void Function() aviso) {}

  _Cuenta _cuentaConSesion() {
    final cuenta = _cuentaActual;
    if (cuenta == null) throw StateError('No hay ninguna sesión iniciada.');
    return cuenta;
  }

  /// "Mari@Ejemplo.com " y "mari@ejemplo.com" son la misma cuenta.
  String _normalizar(String correo) => correo.trim().toLowerCase();
}

class _Cuenta {
  _Cuenta({required this.contrasena, this.pin});

  final String contrasena;

  /// `null` mientras la cuenta no ha creado su PIN.
  String? pin;
}
