import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/modelos/cuenta.dart';
import 'package:mi_puesto/datos/modelos/negocio.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// La cuenta y quién usa el dispositivo, contra el servidor.
///
/// Al entrar, el servidor entrega un "token" (la llave de la sesión); se
/// guarda en el dispositivo para no pedir el correo y la contraseña cada
/// vez. Quién está dentro (el perfil activo) lo recuerda el servidor.
class RepositorioDeSesionHttp implements RepositorioDeSesion {
  RepositorioDeSesionHttp(this._api);

  final ClienteDeApi _api;

  @override
  Future<Cuenta?> consultarCuenta() async {
    if (await _api.leerToken() == null) return null;

    try {
      // De paso comprueba que el token guardado siga vivo.
      final respuesta = await _api.pedir(
        'GET',
        '/cuenta',
        avisarSiSePierdeLaSesion: false,
      );
      return cuentaDeJson(respuesta);
    } on ErrorDelServidor catch (error) {
      if (error.codigoHttp == 401) return null;
      rethrow;
    }
  }

  @override
  Future<Cuenta?> iniciarSesion({
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
      await _api.guardarToken(respuesta['token'] as String);
      return cuentaDeJson(respuesta);
    } on ErrorDelServidor catch (error) {
      if (error.codigo == CodigosDeError.credenciales) return null;
      rethrow;
    }
  }

  @override
  Future<Cuenta> crearCuenta({
    required String nombreDelNegocio,
    required String correo,
    required String contrasena,
  }) async {
    final respuesta = await _api.pedir(
      'POST',
      '/cuenta/registro',
      cuerpo: {
        'nombre': nombreDelNegocio,
        'email': correo,
        'password': contrasena,
      },
      conSesion: false,
    );
    await _api.guardarToken(respuesta['token'] as String);
    return cuentaDeJson(respuesta);
  }

  @override
  Future<Cuenta> crearDuena({
    required String nombre,
    required String pin,
  }) async {
    // El PIN viaja como texto: como número, "0412" perdería el cero.
    final respuesta = await _api.pedir(
      'POST',
      '/perfiles/dueno',
      cuerpo: {'nombre': nombre, 'pin': pin},
    );
    return cuentaDeJson(respuesta);
  }

  @override
  Future<Cuenta?> entrarComoPerfil({
    required String perfilId,
    required String pin,
  }) async {
    try {
      final respuesta = await _api.pedir(
        'POST',
        '/perfiles/$perfilId/entrar',
        cuerpo: {'pin': pin},
      );
      return cuentaDeJson(respuesta);
    } on ErrorDelServidor catch (error) {
      if (error.codigo == CodigosDeError.pinIncorrecto) return null;
      // 429: tras 5 fallos seguidos el servidor bloquea a esa persona.
      if (error.codigoHttp == 429) {
        throw const ErrorDelServidor(
          'Demasiados intentos. Espera 5 minutos para volver a probar.',
          codigoHttp: 429,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> salirDelPerfil() async {
    await _api.pedir('POST', '/perfiles/salir');
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
    await _api.olvidarToken();
  }

  @override
  void avisarSiSePierdeLaSesion(void Function() aviso) {
    _api.alPerderLaSesion = aviso;
  }

  @override
  void avisarSiNoHayNadieDentro(void Function() aviso) {
    _api.alNoHaberNadieDentro = aviso;
  }
}

/// Arma una [Cuenta] con lo que responden el login, `/cuenta` y las rutas
/// para entrar con PIN: todas tienen la misma forma.
Cuenta cuentaDeJson(dynamic json) {
  final negocio = json['negocio'];
  final perfilActivo = json['perfil'];

  return Cuenta(
    negocio: Negocio(
      id: idDeJson(negocio['id']),
      nombre: negocio['nombre'] as String,
      correo: negocio['email'] as String? ?? '',
    ),
    perfiles: [
      for (final perfil in json['perfiles'] as List) perfilDeJson(perfil),
    ],
    perfilActivo: perfilActivo == null ? null : perfilDeJson(perfilActivo),
  );
}

/// Arma un [Perfil]. También lo usa el repositorio de perfiles.
Perfil perfilDeJson(dynamic json) {
  return Perfil(
    id: idDeJson(json['id']),
    nombre: json['nombre'] as String,
    rol: json['rol'] == 'dueno' ? Rol.dueno : Rol.vendedor,
    color: json['color'] as int? ?? 0,
    // Las listas de "¿Quién vende hoy?" solo traen activos y no lo dicen.
    activo: json['activo'] as bool? ?? true,
  );
}
