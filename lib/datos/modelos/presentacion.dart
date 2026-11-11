import 'package:mi_puesto/datos/modelos/dinero.dart';

/// Un tamaño de un producto, con su propio precio: "Chica $15".
class Presentacion {
  const Presentacion({
    required this.id,
    required this.nombre,
    required this.precio,
  });

  /// Vacío mientras el tamaño no se haya guardado en el servidor.
  final String id;

  final String nombre;
  final Dinero precio;

  bool get esNueva => id.isEmpty;
}
