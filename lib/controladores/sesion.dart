import 'package:flutter/foundation.dart';
import 'package:mi_puesto/datos/modelos/puesto.dart';
import 'package:mi_puesto/datos/modelos/vendedor.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Recuerda en qué puesto estamos y quién está vendiendo.
class Sesion extends ChangeNotifier {
  Sesion(this._repositorio);

  final RepositorioDeSesion _repositorio;

  Puesto? _puesto;
  Vendedor? _vendedor;

  /// Nombre del puesto, o vacío mientras todavía se está cargando.
  String get nombreDelPuesto => _puesto?.nombre ?? '';

  /// La persona que vende; `null` hasta que se elige en "¿Quién vende hoy?".
  Vendedor? get vendedor => _vendedor;

  Future<void> cargarPuesto() async {
    _puesto = await _repositorio.obtenerPuesto();
    notifyListeners();
  }

  Future<bool> validarPin(String pin) {
    return _repositorio.validarPin(pin);
  }

  void elegirVendedor(Vendedor vendedor) {
    _vendedor = vendedor;
    notifyListeners();
  }
}
