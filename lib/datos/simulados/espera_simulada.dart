/// Pausa breve que imita lo que tarda en responder un servidor real.
/// Así se pueden ver los indicadores de carga durante el desarrollo.
Future<void> esperaSimulada() {
  return Future.delayed(const Duration(milliseconds: 250));
}
