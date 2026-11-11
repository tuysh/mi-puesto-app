import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/http/crear_uuid.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Registro y consulta de ventas, contra el servidor.
class RepositorioDeVentasHttp implements RepositorioDeVentas {
  RepositorioDeVentasHttp(this._api);

  final ClienteDeApi _api;

  /// La venta que se mandó y se quedó sin respuesta (mala señal). Si se
  /// vuelve a intentar el MISMO pedido, se reúsa su identificador para que
  /// el servidor no lo registre dos veces.
  _VentaSinRespuesta? _sinRespuesta;

  @override
  Future<Venta> registrarVenta({
    required List<LineaPorCobrar> lineas,
    required MetodoDePago metodoDePago,
    Dinero? montoRecibido,
    String nota = '',
  }) async {
    final cuerpo = {
      'metodo_pago': metodoDePago.name,
      'lineas': _lineasAJson(lineas),
      // Sin `monto_recibido`, el servidor entiende "pagó exacto".
      if (montoRecibido != null && metodoDePago == MetodoDePago.efectivo)
        'monto_recibido': dineroAJson(montoRecibido),
      if (nota.isNotEmpty) 'nota': nota,
    };

    final huella = cuerpo.toString();
    final pendiente = _sinRespuesta;
    final uuid = pendiente != null && pendiente.huella == huella
        ? pendiente.uuid
        : crearUuid();

    final dynamic respuesta;
    try {
      respuesta = await _api.pedir(
        'POST',
        '/ventas',
        cuerpo: {'uuid': uuid, ...cuerpo},
      );
    } on ErrorDeConexion {
      // No sabemos si la venta llegó: se recuerda para reintentar igual.
      _sinRespuesta = _VentaSinRespuesta(huella: huella, uuid: uuid);
      rethrow;
    }
    _sinRespuesta = null;

    return _ventaDeJson(respuesta);
  }

  @override
  Future<VentasDelDia> obtenerVentasDelDia(DateTime fecha) async {
    final respuesta = await _api.pedir(
      'GET',
      '/ventas',
      consulta: {'fecha': diaAJson(fecha)},
    );

    return VentasDelDia(
      fecha: diaDeJson(respuesta['fecha']),
      total: dineroDeJson(respuesta['total']),
      cuantas: respuesta['cuantas'] as int,
      canceladas: respuesta['canceladas'] as int,
      ventas: [
        for (final venta in respuesta['ventas'] as List) _ventaDeJson(venta),
      ],
    );
  }

  @override
  Future<Venta> obtenerVenta(String ventaId) async {
    return _ventaDeJson(await _api.pedir('GET', '/ventas/$ventaId'));
  }

  @override
  Future<Venta> editarVenta(
    String ventaId, {
    List<LineaPorCobrar>? lineas,
    MetodoDePago? metodoDePago,
    String? nota,
  }) async {
    final respuesta = await _api.pedir(
      'PATCH',
      '/ventas/$ventaId',
      // Solo se manda lo que cambió.
      cuerpo: {
        if (lineas != null) 'lineas': _lineasAJson(lineas),
        'metodo_pago': ?metodoDePago?.name,
        'nota': ?nota,
      },
    );
    return _ventaDeJson(respuesta);
  }

  @override
  Future<Venta> cancelarVenta(String ventaId) async {
    return _ventaDeJson(await _api.pedir('POST', '/ventas/$ventaId/cancelar'));
  }

  /// No se mandan precios ni total: los pone el servidor.
  List<Map<String, Object>> _lineasAJson(List<LineaPorCobrar> lineas) {
    return [
      for (final linea in lineas)
        {
          'producto_id': idAJson(linea.productoId),
          // Solo va si el producto tiene tamaños.
          if (linea.presentacionId != null)
            'presentacion_id': idAJson(linea.presentacionId!),
          'cantidad': linea.cantidad,
        },
    ];
  }

  Venta _ventaDeJson(dynamic json) {
    return Venta(
      id: idDeJson(json['id']),
      creadaEn: momentoDeJson(json['creada_en']),
      perfilId: idDeJson(json['perfil_id']),
      metodoDePago: json['metodo_pago'] == 'tarjeta'
          ? MetodoDePago.tarjeta
          : MetodoDePago.efectivo,
      total: dineroDeJson(json['total']),
      montoRecibido: dineroONadaDeJson(json['monto_recibido']),
      cambio: dineroONadaDeJson(json['cambio']),
      nota: json['nota'] as String? ?? '',
      editadaEn: momentoONadaDeJson(json['editada_en']),
      canceladaEn: momentoONadaDeJson(json['cancelada_en']),
      lineas: [
        for (final linea in json['lineas'] as List? ?? [])
          LineaDeVenta(
            productoId: idDeJson(linea['producto_id']),
            presentacionId: idONadaDeJson(linea['presentacion_id']),
            nombreDelProducto: linea['nombre_producto'] as String,
            nombreDelTamano: linea['nombre_presentacion'] as String? ?? '',
            cantidad: linea['cantidad'] as int,
            precioUnitario: dineroDeJson(linea['precio_unitario']),
            subtotal: dineroDeJson(linea['subtotal']),
          ),
      ],
      // El historial y el permiso solo vienen al pedir UNA venta.
      eventos: [
        for (final evento in json['eventos'] as List? ?? [])
          EventoDeVenta(
            tipo: evento['tipo'] == 'cancelacion'
                ? TipoDeEvento.cancelacion
                : TipoDeEvento.edicion,
            perfilId: idDeJson(evento['perfil_id']),
            ocurrioEn: momentoDeJson(evento['ocurrio_en']),
          ),
      ],
      sePuedeCambiar: json['se_puede_cambiar'] as bool? ?? false,
    );
  }
}

class _VentaSinRespuesta {
  const _VentaSinRespuesta({required this.huella, required this.uuid});

  /// Un texto que es igual solo para dos pedidos idénticos.
  final String huella;

  final String uuid;
}
