import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/campo_alto.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/encabezado_de_paso.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/tarjeta_de_persona.dart';
import 'package:mi_puesto/pantallas/principal/pantalla_principal.dart';

/// Pantalla 1.4: el tercer y último paso al crear la cuenta. Con este
/// nombre y el [pin] del paso anterior se crea el perfil de la dueña.
/// Solo sale la primera vez.
class PantallaDeTuNombre extends StatefulWidget {
  const PantallaDeTuNombre({super.key, required this.pin});

  /// El PIN que la dueña acaba de elegir.
  final String pin;

  @override
  State<PantallaDeTuNombre> createState() => _EstadoDePantallaDeTuNombre();
}

class _EstadoDePantallaDeTuNombre extends State<PantallaDeTuNombre> {
  /// Lo más largo que puede ser un nombre para que quepa en su tarjeta.
  static const _largoMaximoDelNombre = 20;

  final _nombre = TextEditingController();

  bool _guardando = false;

  String get _nombreLimpio => _nombre.text.trim();

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando || _nombreLimpio.isEmpty) return;

    final sesion = Dependencias.de(context).sesion;
    setState(() => _guardando = true);
    try {
      await sesion.crearDuena(nombre: _nombreLimpio, pin: widget.pin);
      if (!mounted) return;

      // Quien acaba de crear su PIN no tiene que volver a escribirlo.
      reemplazarTodasLasPantallas(context, const PantallaPrincipal());
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo guardar. Intenta otra vez',
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sePuedeGuardar = _nombreLimpio.isNotEmpty && !_guardando;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const EncabezadoDePaso(
                    icono: Icons.person_outline_rounded,
                    paso: 3,
                    titulo: '¿Cómo te llamas?',
                    ayuda:
                        'Con este nombre quedan las ventas que registres. '
                        'Tú llevas el puesto.',
                  ),
                  const SizedBox(height: 22),
                  // Así se va a ver en "¿Quién vende hoy?".
                  ExcludeSemantics(
                    child: SizedBox(
                      width: 169,
                      height: 168,
                      child: TarjetaDePersona(
                        nombre: _nombreLimpio.isEmpty
                            ? 'Tu nombre'
                            : _nombreLimpio,
                        inicial: inicialDe(_nombreLimpio),
                        rol: 'Dueña',
                        colores: Pasteles.rosa,
                        alTocar: null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  CampoAlto(
                    etiqueta: 'Tu nombre',
                    controlador: _nombre,
                    sugerencia: 'Ej. Mari',
                    maximoDeLetras: _largoMaximoDelNombre,
                    // Redibuja para actualizar la tarjeta y el botón.
                    alCambiar: (_) => setState(() {}),
                    alEnviar: _guardar,
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: TextoDeAyuda(
                      'Después puedes agregar a quien vende contigo.',
                      peso: 700,
                    ),
                  ),
                  const SizedBox(height: 22),
                  BotonPrincipal(
                    texto: 'Guardar nombre',
                    alto: 52,
                    tamanoDeTexto: 19,
                    // Sin nombre no se puede seguir: el botón se apaga.
                    alTocar: sePuedeGuardar ? _guardar : null,
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
