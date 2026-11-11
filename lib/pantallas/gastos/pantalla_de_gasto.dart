import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/gasto.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/fechas.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_fecha.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_dinero.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_texto.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/dialogo_de_confirmacion.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/selector_de_segmentos.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/gastos/widgets/selector_de_categoria_de_gasto.dart';

/// Pantalla 4.2: anota un gasto nuevo o cambia uno que ya existía: cuánto
/// fue, en qué, de qué categoría, qué día y si se pagó con efectivo de la
/// caja.
class PantallaDeGasto extends StatefulWidget {
  const PantallaDeGasto({super.key, this.gasto});

  /// El gasto que se va a cambiar; `null` para anotar uno nuevo.
  final Gasto? gasto;

  @override
  State<PantallaDeGasto> createState() => _EstadoDePantallaDeGasto();
}

class _EstadoDePantallaDeGasto extends State<PantallaDeGasto> {
  late final _monto = TextEditingController();
  late final _concepto = TextEditingController();
  late String? _categoriaId;
  late DateTime _fecha;
  late bool _deCaja;

  bool _guardando = false;

  bool get _esNuevo => widget.gasto == null;

  @override
  void initState() {
    super.initState();

    final gasto = widget.gasto;
    if (gasto == null) {
      _categoriaId = null;
      _fecha = hoy();
      // Lo normal es pagar con lo que hay en la caja, si está abierta.
      _deCaja = Dependencias.de(context).caja.estaAbierta;
    } else {
      _monto.text = formatearMontoEditable(gasto.monto);
      _concepto.text = gasto.concepto;
      _categoriaId = gasto.categoriaId;
      _fecha = gasto.fecha;
      _deCaja = gasto.deCaja;
    }
  }

  @override
  void dispose() {
    _monto.dispose();
    _concepto.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: hoy(),
      helpText: '¿Qué día fue el gasto?',
    );
    if (fecha != null) setState(() => _fecha = fecha);
  }

  Future<void> _guardar() async {
    final monto = leerDinero(_monto.text);
    final concepto = _concepto.text.trim();
    if (monto == null || monto.esCero) {
      mostrarAviso(context, 'Escribe cuánto se gastó');
      return;
    }
    if (concepto.isEmpty) {
      mostrarAviso(context, 'Escribe en qué se gastó');
      return;
    }

    final dependencias = Dependencias.de(context);
    setState(() => _guardando = true);
    try {
      await dependencias.conexiones.gastos.guardarGasto(
        Gasto(
          id: widget.gasto?.id ?? '',
          concepto: concepto,
          monto: monto,
          fecha: _fecha,
          categoriaId: _categoriaId,
          deCaja: _deCaja,
        ),
      );
      if (!mounted) return;

      cerrarPantalla(context);
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo guardar el gasto',
        );
        setState(() => _guardando = false);
      }
    }
  }

  Future<void> _eliminar() async {
    final repositorio = Dependencias.de(context).conexiones.gastos;

    final confirmo = await pedirConfirmacion(
      context,
      titulo: '¿Eliminar este gasto?',
      mensaje: 'Deja de contar en los reportes. No se puede deshacer.',
      textoDeConfirmar: 'Eliminar',
    );
    if (!confirmo) return;

    try {
      await repositorio.eliminarGasto(widget.gasto!.id);
      if (mounted) cerrarPantalla(context);
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo eliminar el gasto',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MarcoDePantalla(
      child: ColumnaConPie(
        espacio: 14,
        pie: BotonPrincipal(
          texto: _esNuevo ? 'Guardar gasto' : 'Guardar cambios',
          icono: Icons.check_rounded,
          iconoAlFinal: true,
          alTocar: _guardando ? null : _guardar,
        ),
        children: [
          EncabezadoConVolver(
            titulo: _esNuevo ? 'Anotar gasto' : 'Editar gasto',
            accion: _esNuevo
                ? null
                : BotonDeEnlace(texto: 'Eliminar', alTocar: _eliminar),
          ),
          CampoEtiquetado(
            etiqueta: '¿Cuánto se gastó?',
            tamanoDeEtiqueta: 17,
            child: CampoDeDinero(controlador: _monto),
          ),
          CampoEtiquetado(
            etiqueta: '¿En qué?',
            child: CampoDeTexto(
              controlador: _concepto,
              sugerencia: 'Ej. tanque de gas',
            ),
          ),
          SelectorDeCategoriaDeGasto(
            elegida: _categoriaId,
            alElegir: (categoriaId) =>
                setState(() => _categoriaId = categoriaId),
          ),
          CampoEtiquetado(
            etiqueta: 'Fecha',
            child: BotonDeFecha(
              texto: formatearFechaConHoy(_fecha),
              alTocar: _elegirFecha,
            ),
          ),
          CampoEtiquetado(
            etiqueta: '¿Lo pagaste con efectivo de la caja?',
            child: SelectorDeSegmentos<bool>.grande(
              opciones: const {true: 'Sí, de la caja', false: 'No, aparte'},
              elegida: _deCaja,
              alElegir: (deCaja) => setState(() => _deCaja = deCaja),
            ),
          ),
          TextoDeAyuda(
            _deCaja
                ? 'Se descuenta de lo que debe haber al cerrar caja.'
                : 'No toca la caja.',
            peso: 700,
          ),
        ],
      ),
    );
  }
}
