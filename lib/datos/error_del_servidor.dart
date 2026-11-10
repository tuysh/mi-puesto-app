/// Algo que el servidor no aceptó (o que no se pudo ni pedir), con un
/// [mensaje] en español que se puede mostrar tal cual a la persona.
///
/// Los repositorios lanzan este error cuando hay una razón que explicar:
/// "Ya hay una cuenta con ese correo.", "Pagó con menos del total."…
class ErrorDelServidor implements Exception {
  const ErrorDelServidor(this.mensaje, {this.codigo});

  final String mensaje;

  /// El código HTTP de la respuesta (400, 403, 409…); `null` si el error
  /// no viene de una respuesta del servidor (por ejemplo, sin internet).
  final int? codigo;

  @override
  String toString() => 'ErrorDelServidor($codigo): $mensaje';
}
