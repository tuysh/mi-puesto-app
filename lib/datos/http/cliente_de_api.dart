import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/http/almacen_de_sesion.dart';

/// Habla con la API v1 del servidor: arma las direcciones, manda el token
/// de la sesión, convierte el JSON y traduce los errores a
/// [ErrorDelServidor].
///
/// Todos los repositorios `…Http` comparten un mismo cliente.
class ClienteDeApi {
  ClienteDeApi({
    required String urlDelServidor,
    required this._almacen,
    http.Client? cliente,
  }) : _base = Uri.parse(urlDelServidor),
       _http = cliente ?? http.Client();

  final Uri _base;
  final AlmacenDeSesion _almacen;
  final http.Client _http;

  /// Lo más que se espera una respuesta antes de darla por perdida.
  static const _esperaMaxima = Duration(seconds: 20);

  SesionGuardada? _sesion;
  bool _yaSeLeyoElAlmacen = false;

  /// Se llama cuando el servidor deja de reconocer la sesión (por ejemplo,
  /// porque se cerró desde otro lado) en medio del uso de la aplicación.
  void Function()? alPerderLaSesion;

  /// La sesión de este dispositivo, o `null` si no hay ninguna.
  Future<SesionGuardada?> leerSesion() async {
    if (!_yaSeLeyoElAlmacen) {
      _sesion = await _almacen.leer();
      _yaSeLeyoElAlmacen = true;
    }
    return _sesion;
  }

  Future<void> guardarSesion(SesionGuardada sesion) async {
    _sesion = sesion;
    _yaSeLeyoElAlmacen = true;
    await _almacen.guardar(sesion);
  }

  Future<void> olvidarSesion() async {
    _sesion = null;
    _yaSeLeyoElAlmacen = true;
    await _almacen.borrar();
  }

  /// El inicio de casi todas las rutas: `/puestos/<id del puesto>`.
  Future<String> rutaDelPuesto() async {
    final sesion = await leerSesion();
    if (sesion == null) throw const _SesionCerrada();
    return '/puestos/${sesion.puestoId}';
  }

  /// Hace una petición y devuelve el JSON de la respuesta ya convertido
  /// (un `Map`, una `List`…), o `null` si la respuesta no trae cuerpo.
  ///
  /// - [metodo]: `GET`, `POST`, `PUT`, `PATCH` o `DELETE`.
  /// - [ruta]: lo que va después de `/api/v1`, por ejemplo `/cuenta/login`.
  /// - [consulta]: los parámetros que van después del `?`.
  /// - [cuerpo]: lo que se manda como JSON.
  /// - [conSesion]: `false` solo para registro y login, que no llevan token.
  /// - [avisarSiSePierdeLaSesion]: `false` cuando quien llama ya se encarga
  ///   de mandar a "Inicia sesión" si el servidor responde 401.
  Future<dynamic> pedir(
    String metodo,
    String ruta, {
    Map<String, String>? consulta,
    Object? cuerpo,
    bool conSesion = true,
    bool avisarSiSePierdeLaSesion = true,
  }) async {
    final direccion = _base.replace(
      path: '${_base.path.replaceFirst(RegExp(r'/$'), '')}/api/v1$ruta',
      queryParameters: consulta,
    );

    final peticion = http.Request(metodo, direccion);
    peticion.headers['Accept'] = 'application/json';
    if (conSesion) {
      final sesion = await leerSesion();
      if (sesion == null) throw const _SesionCerrada();
      peticion.headers['Authorization'] = 'Bearer ${sesion.token}';
    }
    if (cuerpo != null) {
      peticion.headers['Content-Type'] = 'application/json';
      peticion.body = jsonEncode(cuerpo);
    } else if (metodo != 'GET' && metodo != 'DELETE') {
      // El servidor pide este encabezado en todo POST, aunque vaya vacío.
      peticion.headers['Content-Type'] = 'application/json';
    }

    final http.Response respuesta;
    try {
      respuesta = await _http
          .send(peticion)
          .then(http.Response.fromStream)
          .timeout(_esperaMaxima);
    } catch (_) {
      // Sin señal, servidor apagado, respuesta que nunca llegó…
      throw const ErrorDeConexion();
    }

    if (respuesta.statusCode >= 400) {
      if (respuesta.statusCode == 401 && conSesion) {
        await olvidarSesion();
        if (avisarSiSePierdeLaSesion) alPerderLaSesion?.call();
        throw const _SesionCerrada();
      }
      throw ErrorDelServidor(
        _mensajeDeError(respuesta),
        codigo: respuesta.statusCode,
      );
    }

    if (respuesta.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(respuesta.bodyBytes));
  }

  /// Saca de una respuesta de error el texto para mostrar.
  ///
  /// El servidor manda `{"detail": "…"}` o, en los 400, una lista de
  /// mensajes por campo: `{"nombre": ["…"], "precio": ["…"]}`.
  String _mensajeDeError(http.Response respuesta) {
    if (respuesta.statusCode == 429) {
      return 'Demasiados intentos. Espera unos minutos.';
    }

    final mensajes = <String>[];
    try {
      _juntarMensajes(jsonDecode(utf8.decode(respuesta.bodyBytes)), mensajes);
    } catch (_) {
      // El cuerpo no era JSON (por ejemplo, una página de error 502).
    }
    if (mensajes.isNotEmpty) return mensajes.join(' ');

    return respuesta.statusCode >= 500
        ? 'El servidor no está disponible. Intenta más tarde.'
        : 'El servidor no aceptó la petición.';
  }

  /// Recorre el JSON del error y junta todos los textos que encuentre.
  void _juntarMensajes(Object? json, List<String> mensajes) {
    if (json is String) {
      mensajes.add(json);
    } else if (json is List) {
      for (final parte in json) {
        _juntarMensajes(parte, mensajes);
      }
    } else if (json is Map) {
      for (final parte in json.values) {
        _juntarMensajes(parte, mensajes);
      }
    }
  }
}

/// No se pudo hablar con el servidor: no llegó ninguna respuesta.
class ErrorDeConexion extends ErrorDelServidor {
  const ErrorDeConexion()
    : super('No hay conexión con el servidor. Revisa tu internet.');
}

/// El servidor ya no reconoce la sesión de este dispositivo.
class _SesionCerrada extends ErrorDelServidor {
  const _SesionCerrada()
    : super('La sesión se cerró. Vuelve a iniciar sesión.', codigo: 401);
}
