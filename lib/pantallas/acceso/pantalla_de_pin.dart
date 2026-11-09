import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/logo_del_puesto.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/puntos_de_pin.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/teclado_de_pin.dart';
import 'package:mi_puesto/pantallas/vendedores/pantalla_quien_vende.dart';

/// Pantalla 1: pide el PIN del puesto para poder entrar.
class PantallaDePin extends StatefulWidget {
  const PantallaDePin({super.key});

  @override
  State<PantallaDePin> createState() => _EstadoDePantallaDePin();
}

class _EstadoDePantallaDePin extends State<PantallaDePin> {
  static const _largoDelPin = 4;

  String _pin = '';
  bool _pinIncorrecto = false;
  bool _validando = false;

  bool get _pinCompleto => _pin.length == _largoDelPin;

  void _agregarDigito(String digito) {
    if (_pinCompleto) return;

    setState(() {
      _pin += digito;
      _pinIncorrecto = false;
    });
  }

  void _borrarDigito() {
    if (_pin.isEmpty) return;

    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _entrar() async {
    setState(() => _validando = true);
    final esCorrecto = await Dependencias.de(context).sesion.validarPin(_pin);

    // Si la pantalla se cerró mientras se validaba, ya no hay nada que hacer.
    if (!mounted) return;

    if (esCorrecto) {
      reemplazarPantalla(context, const PantallaQuienVende());
      return;
    }

    setState(() {
      _pin = '';
      _pinIncorrecto = true;
      _validando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sesion = Dependencias.de(context).sesion;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              children: [
                const LogoDelPuesto(),
                const SizedBox(height: 24),
                ListenableBuilder(
                  listenable: sesion,
                  builder: (context, _) => Text(
                    sesion.nombreDelPuesto,
                    textAlign: TextAlign.center,
                    style: Tipografia.titulo(30),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _pinIncorrecto
                      ? 'PIN incorrecto. Intenta otra vez'
                      : 'Escribe el PIN del puesto',
                  style: Tipografia.texto(
                    17,
                    peso: 600,
                    color: _pinIncorrecto ? Colores.acento : Colores.tintaSuave,
                  ),
                ),
                const SizedBox(height: 36),
                PuntosDePin(llenos: _pin.length, total: _largoDelPin),
                const SizedBox(height: 44),
                TecladoDePin(
                  alTocarDigito: _agregarDigito,
                  alBorrar: _borrarDigito,
                ),
                const SizedBox(height: 22),
                // El botón siempre ocupa su lugar, aunque esté invisible,
                // para que el teclado no brinque al completar el PIN.
                Visibility.maintain(
                  visible: _pinCompleto,
                  child: BotonPrincipal(
                    texto: 'Entrar',
                    alto: 52,
                    tamanoDeTexto: 19,
                    alTocar: _validando ? null : _entrar,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
