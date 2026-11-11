/// Algo que el servidor no aceptó (o que no se pudo ni pedir), con un
/// [mensaje] en español que se puede mostrar tal cual a la persona.
///
/// Los repositorios lanzan este error cuando hay una razón que explicar:
/// "Ya hay una cuenta con ese correo.", "Pagó con menos del total."…
class ErrorDelServidor implements Exception {
  const ErrorDelServidor(this.mensaje, {this.codigoHttp, this.codigo});

  final String mensaje;

  /// El código HTTP de la respuesta (400, 403, 409…); `null` si el error
  /// no viene de una respuesta del servidor (por ejemplo, sin internet).
  final int? codigoHttp;

  /// La palabra con la que el servidor dice qué pasó, para que la
  /// aplicación decida qué hacer: `sin_caja`, `pin_incorrecto`… (ver
  /// [CodigosDeError]). `null` si la respuesta no trae ninguna.
  final String? codigo;

  @override
  String toString() => 'ErrorDelServidor($codigoHttp, $codigo): $mensaje';
}

/// No se pudo hablar con el servidor: no llegó ninguna respuesta.
class ErrorDeConexion extends ErrorDelServidor {
  const ErrorDeConexion()
    : super('No hay conexión con el servidor. Revisa tu internet.');
}

/// Los códigos de error del servidor que la aplicación revisa.
abstract final class CodigosDeError {
  /// Nadie ha escrito su PIN en este dispositivo.
  static const sinPerfil = 'sin_perfil';

  static const pinIncorrecto = 'pin_incorrecto';

  /// El correo o la contraseña no son correctos.
  static const credenciales = 'credenciales';

  /// No hay caja abierta: no se puede vender.
  static const sinCaja = 'sin_caja';

  /// El producto tiene ventas: no se puede borrar, solo desactivar.
  static const conHistoria = 'con_historia';
}
