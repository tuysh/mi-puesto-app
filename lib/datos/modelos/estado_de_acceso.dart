import 'package:mi_puesto/datos/modelos/cuenta.dart';

/// Qué tan lejos llegó este dispositivo en el camino para entrar.
/// Con esto la aplicación decide qué pantalla abrir.
enum EstadoDeAcceso {
  /// Nadie ha iniciado sesión: toca "Inicia sesión".
  sinSesion,

  /// Hay sesión, pero el registro quedó a medias: toca "Crea tu PIN".
  faltaLaDuena,

  /// Hay sesión, pero nadie ha escrito su PIN: toca "¿Quién vende hoy?".
  faltaElegirPersona,

  /// Ya hay alguien dentro: toca la aplicación.
  dentro,
}

/// El paso en el que va el dispositivo según lo que respondió el servidor.
/// [cuenta] es `null` cuando no hay sesión.
EstadoDeAcceso estadoDeAccesoDe(Cuenta? cuenta) {
  if (cuenta == null) return EstadoDeAcceso.sinSesion;
  if (!cuenta.tieneDueno) return EstadoDeAcceso.faltaLaDuena;
  if (cuenta.perfilActivo == null) return EstadoDeAcceso.faltaElegirPersona;
  return EstadoDeAcceso.dentro;
}
