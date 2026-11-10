import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/modelos/vendedor.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Las personas que venden, contra el servidor.
class RepositorioDeVendedoresHttp implements RepositorioDeVendedores {
  RepositorioDeVendedoresHttp(this._api);

  final ClienteDeApi _api;

  @override
  Future<List<Vendedor>> obtenerVendedores() async {
    final puesto = await _api.pedir('GET', await _api.rutaDelPuesto());
    return [
      for (final vendedor in puesto['vendedores'] as List)
        _vendedorDeJson(vendedor),
    ];
  }

  @override
  Future<Vendedor> agregarVendedor(String nombre) async {
    final vendedor = await _api.pedir(
      'POST',
      '${await _api.rutaDelPuesto()}/vendedores',
      cuerpo: {'nombre': nombre},
    );
    return _vendedorDeJson(vendedor);
  }

  Vendedor _vendedorDeJson(dynamic json) {
    final id = json['id'] as int;

    return Vendedor(
      id: idDeJson(id),
      nombre: json['nombre'] as String,
      // El servidor no guarda colores de personas: se reparten según el
      // id, así cada quien conserva siempre el mismo.
      colores: Pasteles.paraIndice(id - 1),
    );
  }
}
