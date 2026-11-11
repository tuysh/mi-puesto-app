import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Lo que una persona puede hacer en la aplicación.
enum Rol {
  /// Lleva el puesto: puede todo.
  dueno,

  /// Solo vende y ve las ventas que registró.
  vendedor,
}

/// Una persona del negocio. Cada quien entra con su propio PIN.
class Perfil {
  const Perfil({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.color,
    this.activo = true,
  });

  final String id;
  final String nombre;
  final Rol rol;

  /// Número del pastel de su círculo, de 0 a 4 (ver `Pasteles.todos`).
  final int color;

  /// Si es `false`, la persona está desactivada: ya no aparece en
  /// "¿Quién vende hoy?", pero sus ventas se conservan.
  final bool activo;

  bool get esDueno => rol == Rol.dueno;

  /// Colores de su círculo con la inicial.
  ParDeColores get colores => Pasteles.paraIndice(color);

  /// Primera letra del nombre, en mayúscula: "Mari" → "M".
  String get inicial => inicialDe(nombre);

  /// Devuelve una copia con los campos indicados cambiados.
  Perfil copiarCon({String? nombre, bool? activo}) {
    return Perfil(
      id: id,
      nombre: nombre ?? this.nombre,
      rol: rol,
      color: color,
      activo: activo ?? this.activo,
    );
  }
}

/// La primera letra de [nombre], en mayúscula; `?` si está vacío.
String inicialDe(String nombre) {
  final limpio = nombre.trim();
  return limpio.isEmpty ? '?' : limpio[0].toUpperCase();
}
