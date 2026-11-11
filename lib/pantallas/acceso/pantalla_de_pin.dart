import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/avatar_de_inicial.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_volver.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/puntos_de_pin.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/teclado_de_pin.dart';
import 'package:mi_puesto/pantallas/principal/pantalla_principal.dart';

/// Pantalla 1.6: pide el PIN de [perfil] para dejarle entrar.
class PantallaDePin extends StatefulWidget {
  const PantallaDePin({super.key, required this.perfil});

  /// La persona que se eligió en "¿Quién vende hoy?".
  final Perfil perfil;

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
    final sesion = Dependencias.de(context).sesion;

    setState(() => _validando = true);
    final bool esCorrecto;
    try {
      esCorrecto = await sesion.entrar(widget.perfil, _pin);
    } catch (error) {
      // Sin internet, o el PIN quedó bloqueado por demasiados intentos.
      if (!mounted) return;

      mostrarAvisoDeError(
        context,
        error,
        siNoHayExplicacion: 'No se pudo revisar el PIN. Intenta otra vez',
      );
      setState(() {
        _pin = '';
        _validando = false;
      });
      return;
    }

    // Si la pantalla se cerró mientras se validaba, ya no hay nada que hacer.
    if (!mounted) return;

    if (esCorrecto) {
      reemplazarTodasLasPantallas(context, const PantallaPrincipal());
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
    final perfil = widget.perfil;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    AvatarDeInicial(
                      inicial: perfil.inicial,
                      colores: perfil.colores,
                      tamano: 72,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Hola, ${perfil.nombre}',
                      textAlign: TextAlign.center,
                      style: Tipografia.titulo(30),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _pinIncorrecto
                          ? 'PIN incorrecto. Intenta otra vez'
                          : 'Escribe tu PIN para entrar',
                      style: Tipografia.texto(
                        17,
                        peso: 600,
                        color: _pinIncorrecto
                            ? Colores.acento
                            : Colores.tintaSuave,
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
                    // El botón siempre ocupa su lugar, aunque esté
                    // invisible, para que el teclado no brinque al
                    // completar el PIN.
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
            // La flecha va fija arriba a la izquierda, encima de lo demás.
            Positioned(
              left: 18,
              top: 18,
              child: BotonDeVolver(
                etiqueta: 'Volver a elegir persona',
                alTocar: () => cerrarPantalla(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
