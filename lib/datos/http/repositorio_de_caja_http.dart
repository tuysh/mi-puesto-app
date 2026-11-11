import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Abrir y cerrar la caja, y los cierres anteriores, contra el servidor.
class RepositorioDeCajaHttp implements RepositorioDeCaja {
  RepositorioDeCajaHttp(this._api);

  final ClienteDeApi _api;

  @override
  Future<Caja?> obtenerCajaAbierta() async {
    final respuesta = await _api.pedir('GET', '/caja');

    // Sin caja abierta el servidor responde `{"caja": null}`.
    final caja = respuesta['caja'];
    return caja == null ? null : _cajaDeJson(caja);
  }

  @override
  Future<Caja> abrirCaja(Dinero fondoInicial) async {
    final respuesta = await _api.pedir(
      'POST',
      '/caja',
      cuerpo: {'fondo_inicial': dineroAJson(fondoInicial)},
    );
    return _cajaDeJson(respuesta['caja']);
  }

  @override
  Future<Caja> cerrarCaja({
    required Dinero contado,
    required String nota,
  }) async {
    final respuesta = await _api.pedir(
      'POST',
      '/caja/cerrar',
      cuerpo: {'efectivo_contado': dineroAJson(contado), 'nota': nota},
    );
    return _cajaDeJson(respuesta['caja']);
  }

  @override
  Future<PaginaDeCierres> obtenerCierres({String? antes}) async {
    final respuesta = await _api.pedir(
      'GET',
      '/cajas',
      consulta: {'antes': ?antes},
    );

    return PaginaDeCierres(
      cierres: [
        for (final cierre in respuesta['cajas'] as List)
          CierreResumido(
            id: idDeJson(cierre['id']),
            fecha: diaDeJson(cierre['fecha']),
            vendido: dineroDeJson(cierre['vendido']),
            diferencia: dineroDeJson(cierre['diferencia']),
          ),
      ],
      siguiente: idONadaDeJson(respuesta['siguiente']),
    );
  }

  @override
  Future<Caja> obtenerCierre(String cajaId) async {
    final respuesta = await _api.pedir('GET', '/cajas/$cajaId');
    return _cajaDeJson(respuesta['caja']);
  }

  /// Quien solo vende recibe nada más `id`, `fecha` y `abierta`: los
  /// montos que no vienen se quedan en cero.
  Caja _cajaDeJson(dynamic json) {
    return Caja(
      id: idDeJson(json['id']),
      fecha: diaDeJson(json['fecha']),
      abierta: json['abierta'] as bool? ?? true,
      fondoInicial: dineroDeJson(json['fondo_inicial']),
      ventasEnEfectivo: dineroDeJson(json['ventas_efectivo']),
      ventasConTarjeta: dineroDeJson(json['ventas_tarjeta']),
      numeroDeVentas: json['num_ventas'] as int? ?? 0,
      gastosTotales: dineroDeJson(json['gastos_total']),
      gastosDeCaja: dineroDeJson(json['gastos_efectivo']),
      efectivoEsperado: dineroDeJson(json['efectivo_esperado']),
      cerradaEn: momentoONadaDeJson(json['cerrada_en']),
      cerradaPorId: idONadaDeJson(json['cerrada_por_id']),
      efectivoContado: dineroONadaDeJson(json['efectivo_contado']),
      diferencia: dineroONadaDeJson(json['diferencia']),
      nota: json['nota'] as String? ?? '',
    );
  }
}
