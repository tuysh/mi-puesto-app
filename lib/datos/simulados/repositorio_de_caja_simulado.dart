import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/espera_simulada.dart';

class RepositorioDeCajaSimulado implements RepositorioDeCaja {
  @override
  Future<CuentaDeCaja> obtenerCuentaDeCaja() async {
    await esperaSimulada();

    return CuentaDeCaja(
      fecha: DateTime.now(),
      fondoInicial: const Dinero.pesos(500),
      vendidoEnEfectivo: const Dinero.pesos(1240),
    );
  }

  @override
  Future<void> cerrarCaja(CierreDeCaja cierre) async {
    await esperaSimulada();
  }
}
