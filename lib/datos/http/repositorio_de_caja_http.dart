import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';

/// Abrir y cerrar la caja, contra el servidor.
class RepositorioDeCajaHttp implements RepositorioDeCaja {
  RepositorioDeCajaHttp(this._api);

  final ClienteDeApi _api;

  @override
  Future<CuentaDeCaja?> obtenerCuentaDeCaja() async {
    final respuesta = await _api.pedir(
      'GET',
      '${await _api.rutaDelPuesto()}/caja',
    );

    // Sin caja abierta el servidor responde `{"caja": null}`.
    final caja = respuesta['caja'];
    return caja == null ? null : _cuentaDeJson(caja);
  }

  @override
  Future<CuentaDeCaja> abrirCaja(Dinero fondoInicial) async {
    final respuesta = await _api.pedir(
      'POST',
      '${await _api.rutaDelPuesto()}/caja',
      cuerpo: {'fondo_inicial': dineroAJson(fondoInicial)},
    );
    return _cuentaDeJson(respuesta['caja']);
  }

  @override
  Future<void> cerrarCaja(CierreDeCaja cierre) async {
    await _api.pedir(
      'POST',
      '${await _api.rutaDelPuesto()}/caja/cerrar',
      cuerpo: {
        'efectivo_contado': dineroAJson(cierre.contado),
        'nota': cierre.nota,
      },
    );
  }

  CuentaDeCaja _cuentaDeJson(dynamic json) {
    return CuentaDeCaja(
      fecha: momentoDeJson(json['abierta_en']),
      fondoInicial: dineroDeJson(json['fondo_inicial']),
      vendidoEnEfectivo: dineroDeJson(json['vendido_efectivo']),
    );
  }
}
