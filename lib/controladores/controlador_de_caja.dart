import 'package:flutter/foundation.dart';
import 'package:mi_puesto/controladores/estado_de_carga.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Sabe si la caja está abierta y avisa cuando eso cambia. Sin caja
/// abierta nadie puede vender, así que "Vender" depende de esto.
class ControladorDeCaja extends ChangeNotifier {
  ControladorDeCaja(this._repositorio);

  final RepositorioDeCaja _repositorio;

  EstadoDeCarga _estado = EstadoDeCarga.cargando;
  Caja? _caja;
  Object? _error;

  EstadoDeCarga get estado => _estado;

  /// La caja abierta; `null` si está cerrada.
  Caja? get caja => _caja;

  bool get estaAbierta => _caja != null;

  /// Lo que falló la última vez que se cargó; `null` si salió bien.
  Object? get error => _error;

  /// Pide la caja mostrando la rueda de carga.
  Future<void> cargar() async {
    _estado = EstadoDeCarga.cargando;
    notifyListeners();
    await actualizar();
  }

  /// Vuelve a pedir la caja sin mostrar la rueda de carga: después de
  /// vender o de anotar un gasto, para tener los montos al día.
  Future<void> actualizar() async {
    try {
      _caja = await _repositorio.obtenerCajaAbierta();
      _estado = EstadoDeCarga.listo;
      _error = null;
    } catch (error) {
      _estado = EstadoDeCarga.conError;
      _error = error;
    }
    notifyListeners();
  }

  /// Abre la caja con [fondoInicial] (el dinero que hay para dar cambio).
  Future<void> abrir(Dinero fondoInicial) async {
    _caja = await _repositorio.abrirCaja(fondoInicial);
    notifyListeners();
  }

  /// Cierra la caja con lo que se contó y devuelve el cierre, ya con la
  /// diferencia calculada.
  Future<Caja> cerrar({required Dinero contado, required String nota}) async {
    final cierre = await _repositorio.cerrarCaja(contado: contado, nota: nota);
    _caja = null;
    notifyListeners();
    return cierre;
  }

  /// Olvida la caja: al cambiar de persona o cerrar sesión.
  void olvidar() {
    _caja = null;
    _estado = EstadoDeCarga.cargando;
    notifyListeners();
  }
}
