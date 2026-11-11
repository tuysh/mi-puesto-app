import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/http/almacen_de_sesion.dart';

/// Habla con la API v2 del servidor: arma las direcciones, manda el token
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

  String? _token;
  bool _yaSeLeyoElAlmacen = false;

  /// Se llama cuando el servidor deja de reconocer la sesión (por ejemplo,
  /// porque se cerró desde otro lado) en medio del uso de la aplicación.
  void Function()? alPerderLaSesion;

  /// Se llama cuando el servidor responde que nadie ha escrito su PIN en
  /// este dispositivo (`sin_perfil`) en medio del uso de la aplicación.
  void Function()? alNoHaberNadieDentro;

  /// El token de este dispositivo, o `null` si no hay sesión.
  Future<String?> leerToken() async {
    if (!_yaSeLeyoElAlmacen) {
      _token = await _almacen.leerToken();
      _yaSeLeyoElAlmacen = true;
    }
    return _token;
  }

  Future<void> guardarToken(String token) async {
    _token = token;
    _yaSeLeyoElAlmacen = true;
    await _almacen.guardarToken(token);
  }

  Future<void> olvidarToken() async {
    _token = null;
    _yaSeLeyoElAlmacen = true;
    await _almacen.borrarToken();
  }

  /// Hace una petición y devuelve el JSON de la respuesta ya convertido
  /// (un `Map`, una `List`…), o `null` si la respuesta no trae cuerpo.
  ///
  /// - [metodo]: `GET`, `POST`, `PUT`, `PATCH` o `DELETE`.
  /// - [ruta]: lo que va después de `/api/v2`, por ejemplo `/cuenta/login`.
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
    final peticion = http.Request(metodo, _direccion(ruta, consulta));
    if (cuerpo != null) {
      peticion.headers['Content-Type'] = 'application/json';
      peticion.body = jsonEncode(cuerpo);
    } else if (metodo != 'GET' && metodo != 'DELETE') {
      // El servidor pide este encabezado en todo POST, aunque vaya vacío.
      peticion.headers['Content-Type'] = 'application/json';
    }

    return _enviar(
      peticion,
      conSesion: conSesion,
      avisarSiSePierdeLaSesion: avisarSiSePierdeLaSesion,
    );
  }

  /// Sube un archivo con `PUT` y devuelve el JSON de la respuesta.
  ///
  /// Es la única petición que no manda JSON: el archivo viaja como
  /// "formulario con archivos" (multipart), en el campo [campo].
  Future<dynamic> subirArchivo(
    String ruta, {
    required String campo,
    required List<int> bytes,
    required String nombreDeArchivo,
  }) {
    final peticion = http.MultipartRequest('PUT', _direccion(ruta, null));
    peticion.files.add(
      http.MultipartFile.fromBytes(campo, bytes, filename: nombreDeArchivo),
    );

    return _enviar(
      peticion,
      conSesion: true,
      avisarSiSePierdeLaSesion: true,
      // Una foto pesa mucho más que el resto de lo que se manda.
      esperaMaxima: const Duration(seconds: 60),
    );
  }

  /// Convierte la dirección de una foto en una dirección completa. En
  /// desarrollo el servidor la manda sin su inicio (`/media/…`).
  String direccionDeFoto(String fotoUrl) {
    if (!fotoUrl.startsWith('/')) return fotoUrl;
    return _base.replace(path: fotoUrl).toString();
  }

  Uri _direccion(String ruta, Map<String, String>? consulta) {
    return _base.replace(
      path: '${_base.path.replaceFirst(RegExp(r'/$'), '')}/api/v2$ruta',
      queryParameters: consulta,
    );
  }

  /// Manda la petición ya armada, le pone el token y revisa la respuesta.
  Future<dynamic> _enviar(
    http.BaseRequest peticion, {
    required bool conSesion,
    required bool avisarSiSePierdeLaSesion,
    Duration esperaMaxima = _esperaMaxima,
  }) async {
    peticion.headers['Accept'] = 'application/json';
    if (conSesion) {
      final token = await leerToken();
      if (token == null) throw const _SesionCerrada();
      peticion.headers['Authorization'] = 'Bearer $token';
    }

    final http.Response respuesta;
    try {
      respuesta = await _http
          .send(peticion)
          .then(http.Response.fromStream)
          .timeout(esperaMaxima);
    } catch (_) {
      // Sin señal, servidor apagado, respuesta que nunca llegó…
      throw const ErrorDeConexion();
    }

    if (respuesta.statusCode >= 400) {
      if (respuesta.statusCode == 401 && conSesion) {
        await olvidarToken();
        if (avisarSiSePierdeLaSesion) alPerderLaSesion?.call();
        throw const _SesionCerrada();
      }

      final error = _errorDe(respuesta);
      if (error.codigo == CodigosDeError.sinPerfil) {
        alNoHaberNadieDentro?.call();
      }
      throw error;
    }

    if (respuesta.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(respuesta.bodyBytes));
  }

  /// Convierte una respuesta de error en un [ErrorDelServidor].
  ///
  /// El servidor manda `{"detail": "…", "codigo": "…"}` o, en algunos 400,
  /// una lista de mensajes por campo: `{"nombre": ["…"], "pin": ["…"]}`.
  ErrorDelServidor _errorDe(http.Response respuesta) {
    Object? json;
    try {
      json = jsonDecode(utf8.decode(respuesta.bodyBytes));
    } catch (_) {
      // El cuerpo no era JSON (por ejemplo, una página de error 502).
    }

    return ErrorDelServidor(
      _mensajeDeError(respuesta.statusCode, json),
      codigoHttp: respuesta.statusCode,
      codigo: json is Map ? json['codigo'] as String? : null,
    );
  }

  String _mensajeDeError(int codigoHttp, Object? json) {
    if (codigoHttp == 429) {
      return 'Demasiados intentos. Espera unos minutos.';
    }

    final mensajes = <String>[];
    if (json is Map && json['detail'] is String) {
      mensajes.add(json['detail'] as String);
    } else {
      _juntarMensajes(json, mensajes);
    }
    if (mensajes.isNotEmpty) return mensajes.join(' ');

    return codigoHttp >= 500
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

/// El servidor ya no reconoce la sesión de este dispositivo.
class _SesionCerrada extends ErrorDelServidor {
  const _SesionCerrada()
    : super('La sesión se cerró. Vuelve a iniciar sesión.', codigoHttp: 401);
}
