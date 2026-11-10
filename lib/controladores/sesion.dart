import 'package:flutter/foundation.dart';
import 'package:mi_puesto/datos/modelos/estado_de_acceso.dart';
import 'package:mi_puesto/datos/modelos/puesto.dart';
import 'package:mi_puesto/datos/modelos/vendedor.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Recuerda en qué puesto estamos y quién está vendiendo, y se encarga de
/// entrar y salir de la cuenta.
class Sesion extends ChangeNotifier {
  Sesion(this._repositorio) {
    _repositorio.avisarSiSePierdeLaSesion(_olvidarTodo);
  }

  final RepositorioDeSesion _repositorio;

  /// Se llama cuando el servidor deja de reconocer la sesión en medio del
  /// uso. La aplicación lo aprovecha para volver a "Inicia sesión".
  VoidCallback? alPerderLaSesion;

  Puesto? _puesto;
  Vendedor? _vendedor;

  /// Nombre del puesto, o vacío mientras todavía se está cargando.
  String get nombreDelPuesto => _puesto?.nombre ?? '';

  /// La persona que vende; `null` hasta que se elige en "¿Quién vende hoy?".
  Vendedor? get vendedor => _vendedor;

  /// Averigua si ya hay una sesión iniciada en este dispositivo y, si la
  /// hay, carga los datos del puesto.
  Future<EstadoDeAcceso> consultarAcceso() async {
    final estado = await _repositorio.consultarAcceso();
    if (estado != EstadoDeAcceso.sinSesion) await _cargarPuesto();
    return estado;
  }

  /// Inicia sesión con una cuenta que ya existe.
  ///
  /// Devuelve [EstadoDeAcceso.sinSesion] si el correo o la contraseña no
  /// son correctos; si lo son, devuelve lo que sigue: crear el PIN o
  /// escribirlo.
  Future<EstadoDeAcceso> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    final entro = await _repositorio.iniciarSesion(
      correo: correo,
      contrasena: contrasena,
    );
    if (!entro) return EstadoDeAcceso.sinSesion;

    return consultarAcceso();
  }

  /// Crea una cuenta nueva y deja la sesión iniciada con ella. Si el
  /// servidor no la acepta, lanza un `ErrorDelServidor` con la razón.
  Future<void> crearCuenta({
    required String correo,
    required String contrasena,
  }) async {
    await _repositorio.crearCuenta(correo: correo, contrasena: contrasena);
    await _cargarPuesto();
  }

  Future<void> guardarPin(String pin) {
    return _repositorio.guardarPin(pin);
  }

  Future<bool> validarPin(String pin) {
    return _repositorio.validarPin(pin);
  }

  /// Sale de la cuenta y olvida el puesto y a quien estaba vendiendo.
  Future<void> cerrarSesion() async {
    await _repositorio.cerrarSesion();
    _puesto = null;
    _vendedor = null;
    notifyListeners();
  }

  void _olvidarTodo() {
    _puesto = null;
    _vendedor = null;
    notifyListeners();
    alPerderLaSesion?.call();
  }

  void elegirVendedor(Vendedor vendedor) {
    _vendedor = vendedor;
    notifyListeners();
  }

  Future<void> _cargarPuesto() async {
    _puesto = await _repositorio.obtenerPuesto();
    notifyListeners();
  }
}
