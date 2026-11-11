import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/estado_de_acceso.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_de_crear_pin.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_de_iniciar_sesion.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_quien_vende.dart';
import 'package:mi_puesto/pantallas/principal/pantalla_principal.dart';

/// La pantalla que toca abrir según qué tan lejos llegó este dispositivo
/// en el camino para entrar.
Widget pantallaSegunAcceso(EstadoDeAcceso estado) {
  return switch (estado) {
    EstadoDeAcceso.sinSesion => const PantallaDeIniciarSesion(),
    EstadoDeAcceso.faltaLaDuena => const PantallaDeCrearPin(),
    EstadoDeAcceso.faltaElegirPersona => const PantallaQuienVende(),
    EstadoDeAcceso.dentro => const PantallaPrincipal(),
  };
}
