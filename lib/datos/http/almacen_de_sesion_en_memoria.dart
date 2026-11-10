import 'package:mi_puesto/datos/http/almacen_de_sesion.dart';

/// Recuerda la sesión solo mientras la aplicación está abierta.
/// Se usa en las pruebas, donde no hay almacenamiento del dispositivo.
class AlmacenDeSesionEnMemoria implements AlmacenDeSesion {
  AlmacenDeSesionEnMemoria([this._sesion]);

  SesionGuardada? _sesion;

  @override
  Future<SesionGuardada?> leer() async => _sesion;

  @override
  Future<void> guardar(SesionGuardada sesion) async => _sesion = sesion;

  @override
  Future<void> borrar() async => _sesion = null;
}
