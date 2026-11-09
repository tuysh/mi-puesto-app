import 'package:mi_puesto/datos/modelos/vendedor.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/datos_de_ejemplo.dart';
import 'package:mi_puesto/datos/simulados/espera_simulada.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

class RepositorioDeVendedoresSimulado implements RepositorioDeVendedores {
  final List<Vendedor> _vendedores = [...vendedoresDeEjemplo];

  @override
  Future<List<Vendedor>> obtenerVendedores() async {
    await esperaSimulada();
    return List.unmodifiable(_vendedores);
  }

  @override
  Future<Vendedor> agregarVendedor(String nombre) async {
    await esperaSimulada();

    final numero = _vendedores.length + 1;
    final vendedor = Vendedor(
      id: 'vendedor-$numero',
      nombre: nombre,
      colores: Pasteles.paraIndice(_vendedores.length),
    );
    _vendedores.add(vendedor);
    return vendedor;
  }
}
