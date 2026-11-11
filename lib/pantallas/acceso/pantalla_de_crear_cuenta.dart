import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_volver.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/campo_alto.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_de_crear_pin.dart';
import 'package:mi_puesto/pantallas/acceso/parece_correo.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/campo_de_contrasena.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/campo_de_correo.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/encabezado_de_cuenta.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/lienzo_de_cuenta.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/pie_de_cuenta.dart';

/// Pantalla 1.2: crea la cuenta de un negocio nuevo (su nombre, un correo
/// y una contraseña). Se abre encima de "Inicia sesión" y, al terminar,
/// sigue con crear el PIN de la dueña.
class PantallaDeCrearCuenta extends StatefulWidget {
  const PantallaDeCrearCuenta({super.key});

  @override
  State<PantallaDeCrearCuenta> createState() =>
      _EstadoDePantallaDeCrearCuenta();
}

class _EstadoDePantallaDeCrearCuenta extends State<PantallaDeCrearCuenta> {
  static const _largoMinimoDeContrasena = 8;

  final _negocio = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  bool _creando = false;

  @override
  void dispose() {
    _negocio.dispose();
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _crearCuenta() async {
    if (_creando) return;

    final nombreDelNegocio = _negocio.text.trim();
    final correo = _correo.text.trim();
    final contrasena = _contrasena.text;
    if (nombreDelNegocio.isEmpty) {
      mostrarAviso(context, 'Escribe el nombre de tu negocio');
      return;
    }
    if (!pareceCorreo(correo)) {
      mostrarAviso(context, 'Escribe tu correo');
      return;
    }
    if (contrasena.length < _largoMinimoDeContrasena) {
      mostrarAviso(
        context,
        'La contraseña necesita al menos $_largoMinimoDeContrasena caracteres',
      );
      return;
    }

    final sesion = Dependencias.de(context).sesion;
    setState(() => _creando = true);
    try {
      await sesion.crearCuenta(
        nombreDelNegocio: nombreDelNegocio,
        correo: correo,
        contrasena: contrasena,
      );
      if (!mounted) return;

      reemplazarTodasLasPantallas(context, const PantallaDeCrearPin());
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo crear la cuenta. Intenta otra vez',
        );
      }
    } finally {
      if (mounted) setState(() => _creando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LienzoDeCuenta(
      margenDeArriba: 14,
      pie: PieDeCuenta(
        pregunta: '¿Ya tienes cuenta?',
        textoDelBoton: 'Iniciar sesión',
        // "Inicia sesión" es la pantalla que quedó debajo de esta.
        alTocar: () => cerrarPantalla(context),
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: BotonDeVolver(
            etiqueta: 'Volver a iniciar sesión',
            alTocar: () => cerrarPantalla(context),
          ),
        ),
        const EncabezadoDeCuenta(
          titulo: 'Crea tu cuenta',
          explicacion:
              'Una cuenta por negocio. Las ventas se guardan en la nube y '
              'no se pierden si cambias de teléfono.',
        ),
        // Agrupados para que el teléfono ofrezca guardar la contraseña.
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              CampoAlto(
                etiqueta: 'Nombre de tu negocio',
                controlador: _negocio,
                sugerencia: 'Ej. Puesto Doña Mari',
              ),
              CampoDeCorreo(
                controlador: _correo,
                sugerencia: 'tucorreo@ejemplo.com',
              ),
              CampoDeContrasena(
                controlador: _contrasena,
                alEnviar: _crearCuenta,
                esNueva: true,
                ayuda: 'Usa al menos $_largoMinimoDeContrasena caracteres.',
              ),
            ],
          ),
        ),
        BotonPrincipal(
          texto: 'Crear cuenta',
          icono: Icons.arrow_forward_rounded,
          iconoAlFinal: true,
          alTocar: _creando ? null : _crearCuenta,
        ),
      ],
    );
  }
}
