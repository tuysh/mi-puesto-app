import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_de_crear_pin.dart';
import 'package:mi_puesto/pantallas/acceso/parece_correo.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/campo_de_contrasena.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/campo_de_correo.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/encabezado_de_cuenta.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/lienzo_de_cuenta.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/pie_de_cuenta.dart';

/// Pantalla 0B: crea una cuenta nueva con correo y contraseña. Se abre
/// encima de "Inicia sesión" y, al terminar, sigue con crear el PIN.
class PantallaDeCrearCuenta extends StatefulWidget {
  const PantallaDeCrearCuenta({super.key});

  @override
  State<PantallaDeCrearCuenta> createState() =>
      _EstadoDePantallaDeCrearCuenta();
}

class _EstadoDePantallaDeCrearCuenta extends State<PantallaDeCrearCuenta> {
  static const _largoMinimoDeContrasena = 8;

  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  bool _creando = false;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _crearCuenta() async {
    if (_creando) return;

    final correo = _correo.text.trim();
    final contrasena = _contrasena.text;
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
      await sesion.crearCuenta(correo: correo, contrasena: contrasena);
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
          child: IconButton(
            tooltip: 'Volver a iniciar sesión',
            onPressed: () => cerrarPantalla(context),
            icon: const Icon(Icons.chevron_left_rounded, size: 32),
            color: Colores.tinta,
            padding: EdgeInsets.zero,
            // Lleva la flecha al margen, alineada con el título.
            alignment: Alignment.centerLeft,
          ),
        ),
        const EncabezadoDeCuenta(
          titulo: 'Crea tu cuenta',
          explicacion:
              'Con tu cuenta, las ventas se guardan en la nube y no se '
              'pierden si cambias de teléfono.',
        ),
        // Agrupados para que el teléfono ofrezca guardar la contraseña.
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
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
