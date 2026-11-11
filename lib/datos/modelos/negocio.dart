/// El negocio que usa la aplicación. Hay uno por cuenta.
class Negocio {
  const Negocio({required this.id, required this.nombre, required this.correo});

  final String id;
  final String nombre;

  /// El correo con el que se inicia sesión.
  final String correo;
}
