import 'package:flutter/foundation.dart';
import 'package:mi_puesto/controladores/controlador_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Convierte el pedido en una venta registrada y recuerda la última,
/// para mostrar el aviso de "Venta registrada" con el cambio.
class ControladorDeVentas extends ChangeNotifier {
  // `this._repositorio` guarda el parámetro en el campo privado; quien
  // crea el controlador lo escribe sin guion: `repositorio: ...`.
  ControladorDeVentas({required this._repositorio, required this._pedido});

  final RepositorioDeVentas _repositorio;
  final ControladorDePedido _pedido;

  Venta? _ultimaVenta;

  /// La venta cuyo aviso sigue en pantalla; `null` si no hay aviso.
  Venta? get ultimaVenta => _ultimaVenta;

  /// Registra el pedido actual como venta y deja el pedido vacío.
  ///
  /// [montoRecibido] es el dinero que entregó el cliente. Si es `null`, se
  /// entiende que pagó exacto. Con tarjeta no se usa.
  Future<void> registrarVenta({
    required MetodoDePago metodoDePago,
    Dinero? montoRecibido,
    String nota = '',
  }) async {
    _ultimaVenta = await _repositorio.registrarVenta(
      lineas: [
        for (final linea in _pedido.lineas)
          LineaPorCobrar(
            productoId: linea.producto.id,
            presentacionId: linea.presentacion?.id,
            cantidad: linea.cantidad,
          ),
      ],
      metodoDePago: metodoDePago,
      montoRecibido: montoRecibido,
      nota: nota,
    );
    _pedido.vaciar();
    notifyListeners();
  }

  /// Quita el aviso de "Venta registrada" de la pantalla.
  void cerrarAviso() {
    if (_ultimaVenta == null) return;

    _ultimaVenta = null;
    notifyListeners();
  }
}
