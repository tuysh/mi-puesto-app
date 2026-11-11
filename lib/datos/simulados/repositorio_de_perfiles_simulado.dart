import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/servidor_simulado.dart';

/// Las personas del negocio, en memoria.
class RepositorioDePerfilesSimulado implements RepositorioDePerfiles {
  RepositorioDePerfilesSimulado(this._servidor);

  final ServidorSimulado _servidor;

  @override
  Future<List<Perfil>> obtenerPerfiles() async {
    await _servidor.atenderALaDuena();
    return List.unmodifiable(_servidor.perfiles);
  }

  @override
  Future<Perfil> crearPerfil({
    required String nombre,
    required String pin,
  }) async {
    await _servidor.atenderALaDuena();
    _revisarQueElNombreEsteLibre(nombre, perfilId: null);

    final perfil = Perfil(
      id: _servidor.idNuevo(),
      nombre: nombre,
      rol: Rol.vendedor,
      color: _servidor.siguienteColor(_servidor.perfiles),
    );
    _servidor.perfiles.add(perfil);
    _servidor.pines[perfil.id] = pin;
    return perfil;
  }

  @override
  Future<Perfil> cambiarPerfil(
    String perfilId, {
    String? nombre,
    String? pin,
    bool? activo,
  }) async {
    await _servidor.atenderALaDuena();

    final posicion = _servidor.perfiles.indexWhere((p) => p.id == perfilId);
    final actual = _servidor.perfiles[posicion];

    if (nombre != null) {
      _revisarQueElNombreEsteLibre(nombre, perfilId: perfilId);
    }
    if (activo == false && actual.esDueno) {
      throw const ErrorDelServidor(
        'No se puede desactivar a la dueña.',
        codigoHttp: 400,
      );
    }

    if (pin != null) _servidor.pines[perfilId] = pin;
    return _servidor.perfiles[posicion] = actual.copiarCon(
      nombre: nombre,
      activo: activo,
    );
  }

  /// Dos personas activas no pueden llamarse igual. [perfilId] es la
  /// persona que se está cambiando (su propio nombre no cuenta).
  void _revisarQueElNombreEsteLibre(
    String nombre, {
    required String? perfilId,
  }) {
    final yaLoTieneAlguien = _servidor.perfiles.any(
      (perfil) =>
          perfil.activo &&
          perfil.id != perfilId &&
          perfil.nombre.toLowerCase() == nombre.toLowerCase(),
    );
    if (yaLoTieneAlguien) {
      throw const ErrorDelServidor(
        'Ya hay alguien con ese nombre.',
        codigoHttp: 400,
      );
    }
  }
}
