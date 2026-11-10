import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/http/crear_uuid.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/vendedor.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Registro de ventas, contra el servidor.
class RepositorioDeVentasHttp implements RepositorioDeVentas {
  RepositorioDeVentasHttp(this._api);

  final ClienteDeApi _api;

  /// La venta que se mandó y se quedó sin respuesta (mala señal). Si se
  /// vuelve a intentar el MISMO pedido, se reúsa su identificador para que
  /// el servidor no lo registre dos veces.
  _VentaSinRespuesta? _sinRespuesta;

  @override
  Future<Venta> registrarVenta({
    required List<LineaDePedido> lineas,
    required Dinero pagoCon,
    required Vendedor vendedor,
  }) async {
    final totalDelPedido = sumarDinero(lineas.map((linea) => linea.subtotal));
    final pagoExacto = pagoCon == totalDelPedido;

    final huella = _huellaDelPedido(lineas, pagoCon, vendedor);
    final pendiente = _sinRespuesta;
    final uuid = pendiente != null && pendiente.huella == huella
        ? pendiente.uuid
        : crearUuid();

    final dynamic respuesta;
    try {
      respuesta = await _api.pedir(
        'POST',
        '${await _api.rutaDelPuesto()}/ventas',
        cuerpo: {
          'uuid': uuid,
          'vendedor_id': idAJson(vendedor.id),
          'lineas': [
            for (final linea in lineas)
              {
                'producto_id': idAJson(linea.producto.id),
                'cantidad': linea.cantidad,
              },
          ],
          // Sin `pago_con`, el servidor entiende "pagó exacto". No se
          // mandan precios ni total: los pone el servidor.
          if (!pagoExacto) 'pago_con': dineroAJson(pagoCon),
        },
      );
    } on ErrorDeConexion {
      // No sabemos si la venta llegó: se recuerda para reintentar igual.
      _sinRespuesta = _VentaSinRespuesta(huella: huella, uuid: uuid);
      rethrow;
    }
    _sinRespuesta = null;

    final total = dineroDeJson(respuesta['total']);
    return Venta(
      id: idDeJson(respuesta['id']),
      lineas: lineas,
      total: total,
      // `pago_con` viene vacío cuando se pagó exacto.
      pagoCon: respuesta['pago_con'] == null
          ? total
          : dineroDeJson(respuesta['pago_con']),
      vendedor: vendedor,
      fecha: momentoDeJson(respuesta['creada_en']),
    );
  }

  @override
  Future<void> anularVenta(String ventaId) async {
    await _api.pedir(
      'POST',
      '${await _api.rutaDelPuesto()}/ventas/$ventaId/anular',
    );
  }

  /// Un texto que es igual solo para dos pedidos idénticos: mismos
  /// productos y cantidades, mismo pago y misma persona.
  String _huellaDelPedido(
    List<LineaDePedido> lineas,
    Dinero pagoCon,
    Vendedor vendedor,
  ) {
    final renglones = [
      for (final linea in lineas) '${linea.producto.id}x${linea.cantidad}',
    ]..sort();
    return '${vendedor.id}|${pagoCon.centavos}|${renglones.join(',')}';
  }
}

class _VentaSinRespuesta {
  const _VentaSinRespuesta({required this.huella, required this.uuid});

  final String huella;
  final String uuid;
}
