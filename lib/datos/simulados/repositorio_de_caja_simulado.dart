import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/espera_simulada.dart';

/// Una caja de mentira: empieza abierta con los números del diseño. Las
/// ventas que se registran en la aplicación NO cambian lo vendido.
class RepositorioDeCajaSimulado implements RepositorioDeCaja {
  /// La caja abierta; `null` después de cerrarla.
  CuentaDeCaja? _cuenta = CuentaDeCaja(
    fecha: DateTime.now(),
    fondoInicial: const Dinero.pesos(500),
    vendidoEnEfectivo: const Dinero.pesos(1240),
  );

  @override
  Future<CuentaDeCaja?> obtenerCuentaDeCaja() async {
    await esperaSimulada();
    return _cuenta;
  }

  @override
  Future<CuentaDeCaja> abrirCaja(Dinero fondoInicial) async {
    await esperaSimulada();
    if (_cuenta != null) {
      throw const ErrorDelServidor('Ya hay una caja abierta.');
    }

    return _cuenta = CuentaDeCaja(
      fecha: DateTime.now(),
      fondoInicial: fondoInicial,
      vendidoEnEfectivo: Dinero.cero,
    );
  }

  @override
  Future<void> cerrarCaja(CierreDeCaja cierre) async {
    await esperaSimulada();
    if (_cuenta == null) {
      throw const ErrorDelServidor('No hay ninguna caja abierta.');
    }

    _cuenta = null;
  }
}
