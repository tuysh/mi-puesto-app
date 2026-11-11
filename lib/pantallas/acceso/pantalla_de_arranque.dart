import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/estado_de_acceso.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_segun_acceso.dart';

/// Lo primero que se abre: averigua en qué paso va este dispositivo y
/// muestra la pantalla que corresponde (iniciar sesión, crear el PIN,
/// elegir quién vende o la aplicación).
///
/// Si no hay internet, el cargador muestra el aviso "No hay internet" con
/// su botón para intentar otra vez.
class PantallaDeArranque extends StatelessWidget {
  const PantallaDeArranque({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = Dependencias.de(context).sesion;

    return Scaffold(
      body: CargadorDeFuturo<EstadoDeAcceso>(
        cargar: sesion.consultarAcceso,
        construir: (context, estado) => pantallaSegunAcceso(estado),
      ),
    );
  }
}
