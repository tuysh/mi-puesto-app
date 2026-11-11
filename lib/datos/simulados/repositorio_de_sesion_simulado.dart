import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/modelos/cuenta.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/datos_de_ejemplo.dart';
import 'package:mi_puesto/datos/simulados/espera_simulada.dart';
import 'package:mi_puesto/datos/simulados/servidor_simulado.dart';

/// Cuentas de mentira: viven en memoria y se pierden al cerrar.
/// Siempre existe la cuenta de ejemplo (ver `datos_de_ejemplo.dart`).
class RepositorioDeSesionSimulado implements RepositorioDeSesion {
  RepositorioDeSesionSimulado(this._servidor);

  final ServidorSimulado _servidor;

  @override
  Future<Cuenta?> consultarCuenta() async {
    await esperaSimulada();
    return _servidor.haySesion ? _servidor.cuenta : null;
  }

  @override
  Future<Cuenta?> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    await esperaSimulada();

    final correoNormalizado = _normalizar(correo);
    if (_servidor.contrasenas[correoNormalizado] != contrasena) return null;

    // El servidor simulado solo recuerda un negocio a la vez: al volver a
    // la cuenta de ejemplo, se ponen otra vez sus datos.
    final cambioDeCuenta = _servidor.negocio.correo != correoNormalizado;
    if (cambioDeCuenta && correoNormalizado == correoDeEjemplo) {
      _servidor.ponerNegocioDeEjemplo();
    }

    _servidor.haySesion = true;
    _servidor.perfilActivoId = null;
    return _servidor.cuenta;
  }

  @override
  Future<Cuenta> crearCuenta({
    required String nombreDelNegocio,
    required String correo,
    required String contrasena,
  }) async {
    await esperaSimulada();

    final correoNormalizado = _normalizar(correo);
    if (_servidor.contrasenas.containsKey(correoNormalizado)) {
      throw const ErrorDelServidor(
        'Ya hay una cuenta con ese correo.',
        codigoHttp: 400,
      );
    }

    _servidor.contrasenas[correoNormalizado] = contrasena;
    _servidor.ponerNegocioNuevo(
      nombre: nombreDelNegocio,
      correo: correoNormalizado,
    );
    _servidor.haySesion = true;
    return _servidor.cuenta;
  }

  @override
  Future<Cuenta> crearDuena({
    required String nombre,
    required String pin,
  }) async {
    await _servidor.atender();

    if (_servidor.cuenta.tieneDueno) {
      throw const ErrorDelServidor(
        'Este negocio ya tiene dueña.',
        codigoHttp: 409,
        codigo: 'ya_hay_dueno',
      );
    }

    final duena = Perfil(
      id: _servidor.idNuevo(),
      nombre: nombre,
      rol: Rol.dueno,
      color: _servidor.siguienteColor(_servidor.perfiles),
    );
    _servidor.perfiles.add(duena);
    _servidor.pines[duena.id] = pin;
    // Quien acaba de crear su PIN no tiene que volver a escribirlo.
    _servidor.perfilActivoId = duena.id;
    return _servidor.cuenta;
  }

  @override
  Future<Cuenta?> entrarComoPerfil({
    required String perfilId,
    required String pin,
  }) async {
    await _servidor.atender();

    final existe = _servidor.cuenta.perfiles.any((p) => p.id == perfilId);
    if (!existe) {
      throw const ErrorDelServidor(
        'Esa persona ya no está en el negocio.',
        codigoHttp: 404,
      );
    }
    if (_servidor.pines[perfilId] != pin) return null;

    _servidor.perfilActivoId = perfilId;
    return _servidor.cuenta;
  }

  @override
  Future<void> salirDelPerfil() async {
    await _servidor.atender();
    _servidor.perfilActivoId = null;
  }

  @override
  Future<void> cerrarSesion() async {
    await esperaSimulada();
    _servidor.haySesion = false;
    _servidor.perfilActivoId = null;
  }

  /// La sesión simulada nunca se pierde sola: no hay nada que avisar.
  @override
  void avisarSiSePierdeLaSesion(void Function() aviso) {}

  @override
  void avisarSiNoHayNadieDentro(void Function() aviso) {}

  /// "Mari@Ejemplo.com " y "mari@ejemplo.com" son la misma cuenta.
  String _normalizar(String correo) => correo.trim().toLowerCase();
}
