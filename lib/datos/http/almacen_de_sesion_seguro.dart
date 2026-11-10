import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mi_puesto/datos/http/almacen_de_sesion.dart';

/// Guarda la sesión en el almacenamiento cifrado del dispositivo
/// (Keystore en Android, Keychain en iOS).
class AlmacenDeSesionSeguro implements AlmacenDeSesion {
  static const _almacenamiento = FlutterSecureStorage();

  static const _llaveDelToken = 'token';
  static const _llaveDelPuesto = 'puesto_id';

  @override
  Future<SesionGuardada?> leer() async {
    final String? token;
    final String? puestoId;
    try {
      token = await _almacenamiento.read(key: _llaveDelToken);
      puestoId = await _almacenamiento.read(key: _llaveDelPuesto);
    } catch (_) {
      // Pasa, por ejemplo, al reinstalar la aplicación en Android: lo
      // guardado ya no se puede descifrar. Se tira y se pide la cuenta
      // otra vez, en lugar de dejar la aplicación trabada al abrir.
      await _almacenamiento.deleteAll();
      return null;
    }
    if (token == null || puestoId == null) return null;

    return SesionGuardada(token: token, puestoId: puestoId);
  }

  @override
  Future<void> guardar(SesionGuardada sesion) async {
    await _almacenamiento.write(key: _llaveDelToken, value: sesion.token);
    await _almacenamiento.write(key: _llaveDelPuesto, value: sesion.puestoId);
  }

  @override
  Future<void> borrar() async {
    await _almacenamiento.delete(key: _llaveDelToken);
    await _almacenamiento.delete(key: _llaveDelPuesto);
  }
}
