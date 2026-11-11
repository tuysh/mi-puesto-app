/// Dónde se guarda el "token" (la llave de la sesión) entre una apertura de
/// la aplicación y otra, para no pedir la cuenta cada vez.
abstract interface class AlmacenDeSesion {
  /// El token guardado, o `null` si no hay ninguno.
  Future<String?> leerToken();

  Future<void> guardarToken(String token);

  Future<void> borrarToken();
}
