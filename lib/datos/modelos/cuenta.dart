import 'package:mi_puesto/datos/modelos/negocio.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';

/// Lo que el servidor sabe de la sesión de este dispositivo: de qué negocio
/// es, quiénes pueden entrar y quién lo está usando ahora.
class Cuenta {
  const Cuenta({
    required this.negocio,
    required this.perfiles,
    required this.perfilActivo,
  });

  final Negocio negocio;

  /// Las personas activas del negocio: las de "¿Quién vende hoy?".
  final List<Perfil> perfiles;

  /// Quien escribió su PIN en este dispositivo; `null` si nadie.
  final Perfil? perfilActivo;

  /// Una cuenta recién creada no tiene dueña hasta que crea su PIN.
  bool get tieneDueno => perfiles.any((perfil) => perfil.esDueno);
}
