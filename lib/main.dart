import 'package:flutter/material.dart';
import 'package:mi_puesto/app/mi_puesto_app.dart';
import 'package:mi_puesto/datos/conexiones.dart';

/// La dirección del servidor. Para apuntar a otro (por ejemplo, uno en tu
/// computadora) sin tocar el código:
///
/// ```
/// flutter run --dart-define=SERVIDOR=http://10.0.2.2:8000
/// ```
const urlDelServidor = String.fromEnvironment(
  'SERVIDOR',
  defaultValue: 'https://mi-puesto-back.lunita.me',
);

/// Con `flutter run --dart-define=SIMULADO=true` la aplicación no usa el
/// servidor: trabaja con datos de ejemplo que viven en memoria.
const usarDatosSimulados = bool.fromEnvironment('SIMULADO');

void main() {
  final conexiones = usarDatosSimulados
      ? Conexiones.simuladas()
      : Conexiones.http(urlDelServidor: urlDelServidor);

  runApp(MiPuestoApp(conexiones: conexiones));
}
