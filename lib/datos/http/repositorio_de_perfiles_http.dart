import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/repositorio_de_sesion_http.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Las personas del negocio, contra el servidor.
class RepositorioDePerfilesHttp implements RepositorioDePerfiles {
  RepositorioDePerfilesHttp(this._api);

  final ClienteDeApi _api;

  @override
  Future<List<Perfil>> obtenerPerfiles() async {
    final lista = await _api.pedir('GET', '/perfiles');
    return [for (final perfil in lista as List) perfilDeJson(perfil)];
  }

  @override
  Future<Perfil> crearPerfil({
    required String nombre,
    required String pin,
  }) async {
    final perfil = await _api.pedir(
      'POST',
      '/perfiles',
      cuerpo: {'nombre': nombre, 'pin': pin},
    );
    return perfilDeJson(perfil);
  }

  @override
  Future<Perfil> cambiarPerfil(
    String perfilId, {
    String? nombre,
    String? pin,
    bool? activo,
  }) async {
    final perfil = await _api.pedir(
      'PATCH',
      '/perfiles/$perfilId',
      // Solo se manda lo que cambió.
      cuerpo: {'nombre': ?nombre, 'pin': ?pin, 'activo': ?activo},
    );
    return perfilDeJson(perfil);
  }
}
