/// Lo que el dispositivo recuerda para no pedir la cuenta cada vez.
class SesionGuardada {
  const SesionGuardada({required this.token, required this.puestoId});

  /// La llave que identifica a este dispositivo ante el servidor.
  final String token;

  /// El puesto de la cuenta; casi todas las rutas del servidor lo llevan.
  final String puestoId;
}

/// Dónde se guarda la sesión entre una apertura de la aplicación y otra.
abstract interface class AlmacenDeSesion {
  /// La sesión guardada, o `null` si no hay ninguna.
  Future<SesionGuardada?> leer();

  Future<void> guardar(SesionGuardada sesion);

  Future<void> borrar();
}
