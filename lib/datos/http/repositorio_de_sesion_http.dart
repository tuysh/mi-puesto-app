import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/http/almacen_de_sesion.dart';
import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/modelos/estado_de_acceso.dart';
import 'package:mi_puesto/datos/modelos/puesto.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// La cuenta, el puesto y el PIN, contra el servidor.
///
/// Al entrar, el servidor entrega un "token" (la llave de la sesión) y el
/// puesto de la cuenta; los dos se guardan en el dispositivo para no pedir
/// el correo y la contraseña cada vez.
class RepositorioDeSesionHttp implements RepositorioDeSesion {
  RepositorioDeSesionHttp(this._api);

  final ClienteDeApi _api;

  /// El puesto de la cuenta, como llegó en la última respuesta.
  Puesto? _puesto;

  @override
  Future<EstadoDeAcceso> consultarAcceso() async {
    final sesion = await _api.leerSesion();
    if (sesion == null) return EstadoDeAcceso.sinSesion;

    try {
      // De paso comprueba que el token guardado siga vivo.
      final cuenta = await _api.pedir(
        'GET',
        '/cuenta',
        avisarSiSePierdeLaSesion: false,
      );
      return _recordarPuesto(cuenta, puestoId: sesion.puestoId);
    } on ErrorDelServidor catch (error) {
      if (error.codigo == 401) return EstadoDeAcceso.sinSesion;
      rethrow;
    }
  }

  @override
  Future<bool> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final respuesta = await _api.pedir(
        'POST',
        '/cuenta/login',
        cuerpo: {'email': correo, 'password': contrasena},
        conSesion: false,
      );
      await _guardarSesion(respuesta);
      return true;
    } on ErrorDelServidor catch (error) {
      // 401: el correo o la contraseña no son correctos.
      if (error.codigo == 401) return false;
      rethrow;
    }
  }

  @override
  Future<void> crearCuenta({
    required String correo,
    required String contrasena,
  }) async {
    final respuesta = await _api.pedir(
      'POST',
      '/cuenta/registro',
      cuerpo: {'email': correo, 'password': contrasena},
      conSesion: false,
    );
    await _guardarSesion(respuesta);
  }

  @override
  Future<void> cerrarSesion() async {
    try {
      await _api.pedir(
        'POST',
        '/cuenta/logout',
        avisarSiSePierdeLaSesion: false,
      );
    } on ErrorDelServidor {
      // Aunque el servidor no se entere (por ejemplo, sin internet), este
      // dispositivo olvida la sesión: es lo que la persona pidió.
    }
    await _api.olvidarSesion();
    _puesto = null;
  }

  @override
  Future<Puesto> obtenerPuesto() async {
    final recordado = _puesto;
    if (recordado != null) return recordado;

    final respuesta = await _api.pedir('GET', await _api.rutaDelPuesto());
    return _puesto = _puestoDeJson(respuesta);
  }

  @override
  Future<void> guardarPin(String pin) async {
    // El PIN viaja como texto: como número, "0123" perdería el cero.
    await _api.pedir(
      'PUT',
      '${await _api.rutaDelPuesto()}/pin',
      cuerpo: {'pin': pin},
    );
  }

  @override
  Future<bool> validarPin(String pin) async {
    try {
      await _api.pedir(
        'POST',
        '${await _api.rutaDelPuesto()}/pin/verificar',
        cuerpo: {'pin': pin},
      );
      return true;
    } on ErrorDelServidor catch (error) {
      // 403: PIN incorrecto.
      if (error.codigo == 403) return false;
      // 429: tras 5 fallos seguidos el servidor bloquea el PIN 5 minutos.
      if (error.codigo == 429) {
        throw const ErrorDelServidor(
          'Demasiados intentos. Espera 5 minutos para volver a probar.',
          codigo: 429,
        );
      }
      rethrow;
    }
  }

  @override
  void avisarSiSePierdeLaSesion(void Function() aviso) {
    _api.alPerderLaSesion = () {
      _puesto = null;
      aviso();
    };
  }

  /// Guarda en el dispositivo el token y el puesto que llegan al entrar.
  Future<void> _guardarSesion(dynamic respuesta) async {
    final puesto = (respuesta['puestos'] as List).first;
    await _api.guardarSesion(
      SesionGuardada(
        token: respuesta['token'] as String,
        puestoId: idDeJson(puesto['id']),
      ),
    );
    _puesto = _puestoDeJson(puesto);
  }

  /// Busca el puesto de la sesión en la respuesta de `/cuenta` y dice si
  /// ya tiene PIN.
  EstadoDeAcceso _recordarPuesto(dynamic cuenta, {required String puestoId}) {
    final puestos = cuenta['puestos'] as List;
    final puesto = puestos.firstWhere(
      (puesto) => idDeJson(puesto['id']) == puestoId,
      orElse: () => puestos.first,
    );
    _puesto = _puestoDeJson(puesto);

    return puesto['tiene_pin'] == true
        ? EstadoDeAcceso.listo
        : EstadoDeAcceso.faltaElPin;
  }

  Puesto _puestoDeJson(dynamic json) {
    return Puesto(id: idDeJson(json['id']), nombre: json['nombre'] as String);
  }
}
