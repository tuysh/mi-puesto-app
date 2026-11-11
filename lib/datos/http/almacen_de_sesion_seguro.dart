import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mi_puesto/datos/http/almacen_de_sesion.dart';

/// Guarda el token en el almacenamiento cifrado del dispositivo
/// (Keystore en Android, Keychain en iOS).
class AlmacenDeSesionSeguro implements AlmacenDeSesion {
  static const _almacenamiento = FlutterSecureStorage();

  static const _llaveDelToken = 'token';

  @override
  Future<String?> leerToken() async {
    try {
      return await _almacenamiento.read(key: _llaveDelToken);
    } catch (_) {
      // Pasa, por ejemplo, al reinstalar la aplicación en Android: lo
      // guardado ya no se puede descifrar. Se tira y se pide la cuenta
      // otra vez, en lugar de dejar la aplicación trabada al abrir.
      await _almacenamiento.deleteAll();
      return null;
    }
  }

  @override
  Future<void> guardarToken(String token) {
    return _almacenamiento.write(key: _llaveDelToken, value: token);
  }

  @override
  Future<void> borrarToken() {
    return _almacenamiento.delete(key: _llaveDelToken);
  }
}
