import 'package:mi_puesto/datos/http/almacen_de_sesion.dart';

/// Recuerda el token solo mientras la aplicación está abierta.
/// Se usa en las pruebas, donde no hay almacenamiento del dispositivo.
class AlmacenDeSesionEnMemoria implements AlmacenDeSesion {
  AlmacenDeSesionEnMemoria([this._token]);

  String? _token;

  @override
  Future<String?> leerToken() async => _token;

  @override
  Future<void> guardarToken(String token) async => _token = token;

  @override
  Future<void> borrarToken() async => _token = null;
}
