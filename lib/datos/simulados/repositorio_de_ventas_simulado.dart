import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/vendedor.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/espera_simulada.dart';

class RepositorioDeVentasSimulado implements RepositorioDeVentas {
  final List<Venta> _ventas = [];

  /// Número que se usará para el `id` de la siguiente venta.
  int _siguienteNumero = 1;

  @override
  Future<Venta> registrarVenta({
    required List<LineaDePedido> lineas,
    required Dinero pagoCon,
    required Vendedor vendedor,
  }) async {
    await esperaSimulada();

    final venta = Venta(
      id: 'venta-$_siguienteNumero',
      lineas: lineas,
      total: sumarDinero(lineas.map((linea) => linea.subtotal)),
      pagoCon: pagoCon,
      vendedor: vendedor,
      fecha: DateTime.now(),
    );
    _siguienteNumero++;
    _ventas.add(venta);
    return venta;
  }

  @override
  Future<void> anularVenta(String ventaId) async {
    await esperaSimulada();
    _ventas.removeWhere((venta) => venta.id == ventaId);
  }
}
