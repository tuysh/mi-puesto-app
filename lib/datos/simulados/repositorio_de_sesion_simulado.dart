import 'package:mi_puesto/datos/modelos/puesto.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/datos_de_ejemplo.dart';
import 'package:mi_puesto/datos/simulados/espera_simulada.dart';

class RepositorioDeSesionSimulado implements RepositorioDeSesion {
  @override
  Future<Puesto> obtenerPuesto() async {
    await esperaSimulada();
    return puestoDeEjemplo;
  }

  @override
  Future<bool> validarPin(String pin) async {
    await esperaSimulada();
    return pin == pinDeEjemplo;
  }
}
