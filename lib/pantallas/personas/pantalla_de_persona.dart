import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/avatar_de_inicial.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/campo_alto.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/interruptor.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/personas/pedir_pin_nuevo.dart';
import 'package:mi_puesto/pantallas/personas/widgets/campo_de_pin.dart';

/// Pantalla 5.7: agrega a alguien que vende, o cambia a una persona que ya
/// existe: su nombre, su PIN y si puede vender.
///
/// No hay "eliminar": una persona se desactiva y sus ventas se conservan.
class PantallaDePersona extends StatefulWidget {
  const PantallaDePersona({super.key, this.perfil});

  /// La persona que se va a cambiar; `null` para agregar a alguien.
  final Perfil? perfil;

  @override
  State<PantallaDePersona> createState() => _EstadoDePantallaDePersona();
}

class _EstadoDePantallaDePersona extends State<PantallaDePersona> {
  /// Lo más largo que puede ser un nombre para que quepa en su tarjeta.
  static const _largoMaximoDelNombre = 20;

  late final _nombre = TextEditingController(text: widget.perfil?.nombre);
  late bool _puedeVender = widget.perfil?.activo ?? true;

  /// El PIN que se acaba de escribir; `null` si no se ha cambiado.
  String? _pinNuevo;

  bool _guardando = false;

  bool get _esNueva => widget.perfil == null;
  bool get _esLaDuena => widget.perfil?.esDueno ?? false;
  String get _nombreLimpio => _nombre.text.trim();

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _cambiarPin() async {
    final pin = await pedirPinNuevo(context, nombre: _nombreLimpio);
    if (pin != null && mounted) setState(() => _pinNuevo = pin);
  }

  Future<void> _guardar() async {
    final nombre = _nombreLimpio;
    final pin = _pinNuevo;
    if (nombre.isEmpty) {
      mostrarAviso(context, 'Escribe el nombre de la persona');
      return;
    }
    if (_esNueva && pin == null) {
      mostrarAviso(context, 'Ponle un PIN de 4 números');
      return;
    }

    final repositorio = Dependencias.de(context).conexiones.perfiles;
    final perfil = widget.perfil;
    setState(() => _guardando = true);
    try {
      if (perfil == null) {
        await repositorio.crearPerfil(nombre: nombre, pin: pin!);
      } else {
        await repositorio.cambiarPerfil(
          perfil.id,
          // Solo se manda lo que cambió.
          nombre: nombre == perfil.nombre ? null : nombre,
          pin: pin,
          activo: _puedeVender == perfil.activo ? null : _puedeVender,
        );
      }
      if (!mounted) return;

      cerrarPantalla(context);
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo guardar. Intenta otra vez',
        );
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombreParaAyuda = _nombreLimpio.isEmpty
        ? 'esta persona'
        : _nombreLimpio;

    return MarcoDePantalla(
      child: ColumnaConPie(
        pie: BotonPrincipal(
          texto: _esNueva ? 'Agregar persona' : 'Guardar cambios',
          icono: Icons.check_rounded,
          iconoAlFinal: true,
          alTocar: _guardando ? null : _guardar,
        ),
        children: [
          EncabezadoConVolver(
            titulo: _esNueva ? 'Agregar persona' : 'Editar persona',
          ),
          Row(
            spacing: 14,
            children: [
              AvatarDeInicial(
                inicial: inicialDe(_nombreLimpio),
                colores: widget.perfil?.colores ?? Colores.sinCategoria,
                tamano: 64,
              ),
              Expanded(
                child: Text(
                  _esLaDuena
                      ? 'Dueña · lleva el puesto'
                      : 'Vende · sin correo ni contraseña',
                  style: Tipografia.texto(15, color: Colores.tintaSuave),
                ),
              ),
            ],
          ),
          CampoAlto(
            etiqueta: 'Nombre',
            controlador: _nombre,
            maximoDeLetras: _largoMaximoDelNombre,
            // Redibuja para actualizar la inicial y los textos de ayuda.
            alCambiar: (_) => setState(() {}),
          ),
          CampoEtiquetado(
            etiqueta: 'PIN de 4 números',
            child: CampoDePin(
              tienePin: !_esNueva || _pinNuevo != null,
              hayPinNuevo: _pinNuevo != null,
              alCambiar: _cambiarPin,
            ),
          ),
          TextoDeAyuda(
            _esLaDuena
                ? 'Tu PIN no se puede recuperar desde la app: si lo '
                      'olvidas, escríbele al desarrollador.'
                : 'Si $nombreParaAyuda olvida su PIN, tú le pones uno nuevo '
                      'aquí.',
            peso: 700,
          ),
          // A la dueña no se le puede desactivar, y a alguien nuevo no
          // tiene caso agregarlo apagado.
          if (!_esNueva && !_esLaDuena)
            TarjetaDeContorno(
              relleno: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          'Puede vender',
                          style: Tipografia.texto(16, peso: 800),
                        ),
                        const TextoDeAyuda(
                          'Apágalo para desactivarla. Sus ventas se '
                          'conservan.',
                          peso: 700,
                        ),
                      ],
                    ),
                  ),
                  Interruptor(
                    activo: _puedeVender,
                    etiqueta: 'Puede vender',
                    alCambiar: (activo) =>
                        setState(() => _puedeVender = activo),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
