import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/modelos/gasto.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Los gastos del negocio, contra el servidor.
class RepositorioDeGastosHttp implements RepositorioDeGastos {
  RepositorioDeGastosHttp(this._api);

  final ClienteDeApi _api;

  @override
  Future<GastosDelPeriodo> obtenerGastos({
    required DateTime desde,
    required DateTime hasta,
    String? categoriaId,
  }) async {
    final respuesta = await _api.pedir(
      'GET',
      '/gastos',
      consulta: {
        'desde': diaAJson(desde),
        'hasta': diaAJson(hasta),
        'categoria': ?categoriaId,
      },
    );

    return GastosDelPeriodo(
      desde: diaDeJson(respuesta['desde']),
      hasta: diaDeJson(respuesta['hasta']),
      total: dineroDeJson(respuesta['total']),
      gastos: [
        for (final gasto in respuesta['gastos'] as List) _gastoDeJson(gasto),
      ],
    );
  }

  @override
  Future<Gasto> guardarGasto(Gasto gasto) async {
    final categoriaId = gasto.categoriaId;
    final cuerpo = {
      'concepto': gasto.concepto,
      'monto': dineroAJson(gasto.monto),
      'categoria_id': categoriaId == null ? null : idAJson(categoriaId),
      'fecha': diaAJson(gasto.fecha),
      'de_caja': gasto.deCaja,
    };

    final guardado = gasto.esNuevo
        ? await _api.pedir('POST', '/gastos', cuerpo: cuerpo)
        : await _api.pedir('PATCH', '/gastos/${gasto.id}', cuerpo: cuerpo);
    return _gastoDeJson(guardado);
  }

  @override
  Future<void> eliminarGasto(String gastoId) async {
    await _api.pedir('DELETE', '/gastos/$gastoId');
  }

  Gasto _gastoDeJson(dynamic json) {
    return Gasto(
      id: idDeJson(json['id']),
      concepto: json['concepto'] as String,
      monto: dineroDeJson(json['monto']),
      fecha: diaDeJson(json['fecha']),
      categoriaId: idONadaDeJson(json['categoria_id']),
      deCaja: json['de_caja'] as bool? ?? false,
      editable: json['editable'] as bool? ?? true,
    );
  }
}
