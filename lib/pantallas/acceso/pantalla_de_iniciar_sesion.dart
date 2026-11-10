import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/estado_de_acceso.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/logo_del_puesto.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_de_crear_cuenta.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_segun_acceso.dart';
import 'package:mi_puesto/pantallas/acceso/parece_correo.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/campo_de_contrasena.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/campo_de_correo.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/encabezado_de_cuenta.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/lienzo_de_cuenta.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/pie_de_cuenta.dart';

/// Pantalla 0A: se entra con el correo y la contraseña de la cuenta.
/// Solo hace falta una vez por dispositivo; después basta el PIN.
class PantallaDeIniciarSesion extends StatefulWidget {
  const PantallaDeIniciarSesion({super.key});

  @override
  State<PantallaDeIniciarSesion> createState() =>
      _EstadoDePantallaDeIniciarSesion();
}

class _EstadoDePantallaDeIniciarSesion extends State<PantallaDeIniciarSesion> {
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  bool _entrando = false;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_entrando) return;

    final correo = _correo.text.trim();
    final contrasena = _contrasena.text;
    if (!pareceCorreo(correo)) {
      mostrarAviso(context, 'Escribe tu correo');
      return;
    }
    if (contrasena.isEmpty) {
      mostrarAviso(context, 'Escribe tu contraseña');
      return;
    }

    final sesion = Dependencias.de(context).sesion;
    setState(() => _entrando = true);
    try {
      final estado = await sesion.iniciarSesion(
        correo: correo,
        contrasena: contrasena,
      );
      if (!mounted) return;

      if (estado == EstadoDeAcceso.sinSesion) {
        mostrarAviso(context, 'El correo o la contraseña no son correctos');
        return;
      }
      reemplazarTodasLasPantallas(context, pantallaSegunAcceso(estado));
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo iniciar sesión. Intenta otra vez',
        );
      }
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LienzoDeCuenta(
      pie: PieDeCuenta(
        pregunta: '¿Todavía no tienes cuenta?',
        textoDelBoton: 'Crear cuenta',
        alTocar: () => abrirPantalla(context, const PantallaDeCrearCuenta()),
      ),
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 18,
          children: [
            LogoDelPuesto(tamano: 64),
            EncabezadoDeCuenta(
              titulo: 'Inicia sesión',
              explicacion:
                  'Entra con tu cuenta para que las ventas del puesto se '
                  'guarden en la nube.',
            ),
          ],
        ),
        // Agrupados para que el teléfono pueda rellenar correo y contraseña.
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              CampoDeCorreo(controlador: _correo),
              CampoDeContrasena(controlador: _contrasena, alEnviar: _entrar),
              Align(
                alignment: Alignment.centerRight,
                child: BotonDeEnlace(
                  texto: 'Olvidé mi contraseña',
                  // PENDIENTE: no hay diseño ni contrato para recuperarla.
                  alTocar: () =>
                      mostrarAvisoDePendiente(context, 'Recuperar contraseña'),
                ),
              ),
            ],
          ),
        ),
        BotonPrincipal(
          texto: 'Entrar',
          icono: Icons.arrow_forward_rounded,
          iconoAlFinal: true,
          alTocar: _entrando ? null : _entrar,
        ),
      ],
    );
  }
}
