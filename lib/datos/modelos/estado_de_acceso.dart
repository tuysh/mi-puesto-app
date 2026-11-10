/// Qué tan lejos llegó este dispositivo en el camino para entrar.
/// Con esto la aplicación decide qué pantalla abrir.
enum EstadoDeAcceso {
  /// Nadie ha iniciado sesión: toca "Inicia sesión".
  sinSesion,

  /// Hay sesión, pero la cuenta todavía no tiene PIN: toca "Crea el PIN".
  faltaElPin,

  /// Hay sesión y PIN: toca escribir el PIN del puesto.
  listo,
}
