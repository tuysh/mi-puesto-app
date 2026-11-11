import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_de_pin.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/cuadricula_de_personas.dart';

/// Pantalla 1.5: se elige quién va a usar el dispositivo. Al tocar un
/// nombre se pide el PIN de esa persona.
///
/// Las personas se agregan y se desactivan desde Más › Personas, no aquí.
class PantallaQuienVende extends StatelessWidget {
  const PantallaQuienVende({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = Dependencias.de(context).sesion;

    return Scaffold(
      body: SafeArea(
        child: AnchoMaximo(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
            // Se redibuja si cambia la lista de personas.
            child: ListenableBuilder(
              listenable: sesion,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EncabezadoDePantalla(
                    sobretitulo: sesion.nombreDelNegocio,
                    titulo: '¿Quién vende hoy?',
                    tamanoDeTitulo: 34,
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: CuadriculaDePersonas(
                      perfiles: sesion.perfiles,
                      alElegir: (perfil) =>
                          abrirPantalla(context, PantallaDePin(perfil: perfil)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextoDeAyuda(
                    'Toca tu nombre y escribe tu PIN. Cada venta queda a '
                    'nombre de quien la registró.',
                    tamano: 15,
                    centrado: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
