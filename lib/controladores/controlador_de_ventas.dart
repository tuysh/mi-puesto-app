import 'package:flutter/foundation.dart';
import 'package:mi_puesto/controladores/controlador_de_pedido.dart';
import 'package:mi_puesto/controladores/sesion.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Convierte el pedido en una venta registrada y recuerda la última,
/// para mostrar el aviso de "Venta registrada" con el cambio.
class ControladorDeVentas extends ChangeNotifier {
  // `this._repositorio` guarda el parámetro en el campo privado; quien
  // crea el controlador lo escribe sin guion: `repositorio: ...`.
  ControladorDeVentas({
    required this._repositorio,
    required this._pedido,
    required this._sesion,
  });

  final RepositorioDeVentas _repositorio;
  final ControladorDePedido _pedido;
  final Sesion _sesion;

  Venta? _ultimaVenta;

  /// La venta cuyo aviso sigue en pantalla; `null` si no hay aviso.
  Venta? get ultimaVenta => _ultimaVenta;

  /// Registra el pedido actual como venta y deja el pedido vacío.
  ///
  /// [pagoCon] es el dinero que entregó el cliente. Si es `null`, se
  /// entiende que pagó exacto.
  Future<void> registrarVenta({Dinero? pagoCon}) async {
    final vendedor = _sesion.vendedor;
    if (vendedor == null) {
      throw StateError('No se puede vender sin elegir quién vende.');
    }

    _ultimaVenta = await _repositorio.registrarVenta(
      lineas: _pedido.lineas,
      pagoCon: pagoCon ?? _pedido.total,
      vendedor: vendedor,
    );
    _pedido.vaciar();
    notifyListeners();
  }

  /// "Me equivoqué": anula la última venta y devuelve sus productos al
  /// pedido para poder corregirlo.
  Future<void> corregirUltimaVenta() async {
    final venta = _ultimaVenta;
    if (venta == null) return;

    await _repositorio.anularVenta(venta.id);
    _pedido.reemplazarLineas(venta.lineas);
    _ultimaVenta = null;
    notifyListeners();
  }

  /// Quita el aviso de "Venta registrada" de la pantalla.
  void cerrarAviso() {
    if (_ultimaVenta == null) return;

    _ultimaVenta = null;
    notifyListeners();
  }
}
