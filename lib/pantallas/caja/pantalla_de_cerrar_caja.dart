import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/fechas.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_dinero.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_texto.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/dialogo_de_confirmacion.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/caja/pantalla_de_cierre.dart';
import 'package:mi_puesto/pantallas/caja/widgets/banda_de_diferencia.dart';
import 'package:mi_puesto/pantallas/caja/widgets/tarjeta_de_cuenta_de_caja.dart';

/// Pantalla 3.5: muestra cuánto debe haber en la caja, se escribe cuánto
/// se contó y se cierra. Al terminar abre el resumen del cierre.
class PantallaDeCerrarCaja extends StatelessWidget {
  const PantallaDeCerrarCaja({super.key});

  @override
  Widget build(BuildContext context) {
    final repositorio = Dependencias.de(context).conexiones.caja;

    return MarcoDePantalla(
      // Se pide la caja otra vez para tener los montos de este momento.
      child: CargadorDeFuturo<Caja?>(
        cargar: repositorio.obtenerCajaAbierta,
        construir: (context, caja) {
          if (caja == null) return const _AvisoDeQueYaEstaCerrada();
          return _FormularioDeCierre(caja: caja);
        },
      ),
    );
  }
}

class _AvisoDeQueYaEstaCerrada extends StatelessWidget {
  const _AvisoDeQueYaEstaCerrada();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        EncabezadoConVolver(titulo: 'Cerrar caja'),
        TextoDeAyuda('La caja ya está cerrada.', tamano: 17),
      ],
    );
  }
}

class _FormularioDeCierre extends StatefulWidget {
  const _FormularioDeCierre({required this.caja});

  /// La caja abierta, con sus montos de este momento.
  final Caja caja;

  @override
  State<_FormularioDeCierre> createState() => _EstadoDeFormularioDeCierre();
}

class _EstadoDeFormularioDeCierre extends State<_FormularioDeCierre> {
  final _contado = TextEditingController();
  final _nota = TextEditingController();

  bool _cerrando = false;

  @override
  void dispose() {
    _contado.dispose();
    _nota.dispose();
    super.dispose();
  }

  Future<void> _cerrar() async {
    final contado = leerDinero(_contado.text);
    if (contado == null) {
      mostrarAviso(context, 'Escribe cuánto contaste en la caja');
      return;
    }

    final confirmo = await pedirConfirmacion(
      context,
      titulo: '¿Cerrar la caja?',
      mensaje:
          'Cerrar es definitivo: las ventas y los gastos de este día ya no '
          'se podrán cambiar.',
      textoDeConfirmar: 'Cerrar caja',
    );
    if (!confirmo || !mounted) return;

    final caja = Dependencias.de(context).caja;
    setState(() => _cerrando = true);
    try {
      final cierre = await caja.cerrar(
        contado: contado,
        nota: _nota.text.trim(),
      );
      if (!mounted) return;

      reemplazarPantalla(context, PantallaDeCierre(cierre: cierre));
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo cerrar la caja',
        );
        setState(() => _cerrando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final caja = widget.caja;
    final esDeHoy = esElMismoDia(caja.fecha, DateTime.now());
    final contado = leerDinero(_contado.text);

    return ColumnaConPie(
      pie: BotonPrincipal(
        texto: esDeHoy ? 'Cerrar caja de hoy' : 'Cerrar caja',
        icono: Icons.lock_outline_rounded,
        alTocar: _cerrando ? null : _cerrar,
      ),
      children: [
        EncabezadoConVolver(
          titulo: 'Cerrar caja',
          subtitulo: formatearFechaLarga(caja.fecha),
        ),
        TarjetaDeCuentaDeCaja(caja: caja),
        TextoDeAyuda(
          'Lo vendido con tarjeta '
          '(${formatearDinero(caja.ventasConTarjeta)}) no entra a la caja.',
          peso: 700,
        ),
        CampoEtiquetado(
          etiqueta: '¿Cuánto contaste en la caja?',
          tamanoDeEtiqueta: 17,
          child: CampoDeDinero(
            controlador: _contado,
            // Redibuja para actualizar la franja de la diferencia.
            alCambiar: (_) => setState(() {}),
          ),
        ),
        if (contado != null)
          BandaDeDiferencia(
            diferencia: contado - caja.efectivoEsperado,
            detalleSiNoCuadra: 'Cuenta otra vez antes de cerrar',
          ),
        CampoEtiquetado(
          etiqueta: 'Nota (opcional)',
          child: CampoDeTexto(
            controlador: _nota,
            sugerencia: 'Ej. di cambio de más',
            maximoDeLetras: 200,
          ),
        ),
      ],
    );
  }
}
