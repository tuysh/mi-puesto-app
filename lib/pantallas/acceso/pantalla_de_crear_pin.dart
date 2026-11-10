import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/logo_del_puesto.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/puntos_de_pin.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/teclado_de_pin.dart';
import 'package:mi_puesto/pantallas/vendedores/pantalla_quien_vende.dart';

/// Pantalla 0C: la cuenta nueva elige el PIN del puesto. Se escribe dos
/// veces (paso 1 y paso 2) para estar seguros de que no hubo un dedazo.
class PantallaDeCrearPin extends StatefulWidget {
  const PantallaDeCrearPin({super.key});

  @override
  State<PantallaDeCrearPin> createState() => _EstadoDePantallaDeCrearPin();
}

class _EstadoDePantallaDeCrearPin extends State<PantallaDeCrearPin> {
  static const _largoDelPin = 4;

  /// El PIN que se escribió en el paso 1; vacío mientras seguimos en él.
  String _primerPin = '';

  /// Lo que se lleva escrito en el paso actual.
  String _pin = '';

  bool _guardando = false;

  bool get _esElSegundoPaso => _primerPin.isNotEmpty;
  bool get _pinCompleto => _pin.length == _largoDelPin;
  bool get _coincide => _esElSegundoPaso && _pinCompleto && _pin == _primerPin;
  bool get _noCoincide =>
      _esElSegundoPaso && _pinCompleto && _pin != _primerPin;

  void _agregarDigito(String digito) {
    if (_pinCompleto) return;

    setState(() => _pin += digito);
  }

  void _borrarDigito() {
    if (_pin.isEmpty) return;

    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _continuar() {
    setState(() {
      _primerPin = _pin;
      _pin = '';
    });
  }

  void _empezarDeNuevo() {
    setState(() {
      _primerPin = '';
      _pin = '';
    });
  }

  Future<void> _guardar() async {
    final sesion = Dependencias.de(context).sesion;

    setState(() => _guardando = true);
    try {
      await sesion.guardarPin(_pin);
      if (!mounted) return;

      // Quien acaba de crear el PIN no tiene que volver a escribirlo.
      reemplazarPantalla(context, const PantallaQuienVende());
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo guardar el PIN',
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String get _ayuda {
    if (_noCoincide) return 'No es igual al primero. Empieza de nuevo.';
    if (_esElSegundoPaso) return 'Escríbelo otra vez para confirmarlo.';
    return 'Elige 4 números. Quien venda contigo lo usa para abrir la app.';
  }

  /// El botón de abajo cambia según el paso; `null` si todavía no toca.
  Widget? get _boton {
    if (_coincide) {
      return BotonPrincipal(
        texto: 'Guardar PIN',
        alto: 52,
        tamanoDeTexto: 19,
        alTocar: _guardando ? null : _guardar,
      );
    }
    if (_noCoincide) {
      return BotonDeContorno(
        texto: 'Empezar de nuevo',
        alto: 52,
        alTocar: _empezarDeNuevo,
      );
    }
    if (_pinCompleto) {
      return BotonPrincipal(
        texto: 'Continuar',
        alto: 52,
        tamanoDeTexto: 19,
        alTocar: _continuar,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              children: [
                const LogoDelPuesto(
                  tamano: 60,
                  icono: Icons.lock_outline_rounded,
                ),
                const SizedBox(height: 20),
                Text(
                  _esElSegundoPaso ? 'Paso 2 de 2' : 'Paso 1 de 2',
                  style: Tipografia.texto(
                    14,
                    peso: 800,
                    color: Colores.tintaSuave,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _esElSegundoPaso ? 'Repite el PIN' : 'Crea el PIN del puesto',
                  textAlign: TextAlign.center,
                  style: Tipografia.titulo(30),
                ),
                const SizedBox(height: 8),
                // Alto fijo para dos renglones: así el teclado no brinca
                // cuando el texto cambia de largo.
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 46),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      _ayuda,
                      textAlign: TextAlign.center,
                      style: Tipografia.texto(
                        16,
                        peso: _noCoincide ? 800 : 600,
                        color: _noCoincide
                            ? Pasteles.rosa.tinta
                            : Colores.tintaSuave,
                        altura: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                PuntosDePin(llenos: _pin.length, total: _largoDelPin),
                const SizedBox(height: 30),
                TecladoDePin(
                  alTocarDigito: _agregarDigito,
                  alBorrar: _borrarDigito,
                ),
                const SizedBox(height: 22),
                // El hueco del botón siempre ocupa su lugar, aunque esté
                // vacío, para que el teclado no brinque al completar el PIN.
                SizedBox(height: 56, child: Center(child: _boton)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
