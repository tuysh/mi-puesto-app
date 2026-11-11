import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_de_tu_nombre.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/encabezado_de_paso.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/puntos_de_pin.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/teclado_de_pin.dart';

/// Pantalla 1.3: la dueña de una cuenta nueva elige su PIN. Se escribe dos
/// veces (paso 1 y paso 2) para estar seguros de que no hubo un dedazo.
///
/// Aquí todavía no se guarda nada: el PIN se manda al servidor junto con
/// el nombre, en el paso 3 ([PantallaDeTuNombre]).
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

  void _guardar() {
    abrirPantalla(context, PantallaDeTuNombre(pin: _pin));
  }

  String get _ayuda {
    if (_noCoincide) return 'No es igual al primero. Empieza de nuevo.';
    if (_esElSegundoPaso) return 'Escríbelo otra vez para confirmarlo.';
    return 'Elige 4 números solo tuyos. No se puede recuperar aquí: si lo '
        'olvidas, escríbele al desarrollador.';
  }

  /// El botón de abajo cambia según el paso; `null` si todavía no toca.
  Widget? get _boton {
    if (_coincide) {
      return BotonPrincipal(
        texto: 'Guardar PIN',
        alto: 52,
        tamanoDeTexto: 19,
        alTocar: _guardar,
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
                EncabezadoDePaso(
                  icono: Icons.lock_outline_rounded,
                  paso: _esElSegundoPaso ? 2 : 1,
                  titulo: _esElSegundoPaso ? 'Repite el PIN' : 'Crea tu PIN',
                  ayuda: _ayuda,
                  ayudaEsUnError: _noCoincide,
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
