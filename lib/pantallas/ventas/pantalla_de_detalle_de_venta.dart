import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/controladores/sesion.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/banda_de_aviso.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/dialogo_de_confirmacion.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/tarjeta_de_pedido.dart';
import 'package:mi_puesto/pantallas/ventas/pantalla_de_editar_venta.dart';
import 'package:mi_puesto/pantallas/ventas/widgets/historial_de_venta.dart';
import 'package:mi_puesto/pantallas/ventas/widgets/tarjeta_de_pago_y_nota.dart';

/// Pantalla 3.3: una venta completa: qué se llevó, cómo se pagó, su nota y
/// quién la ha editado o cancelado. La dueña puede editarla o cancelarla
/// mientras la caja de ese día siga abierta.
class PantallaDeDetalleDeVenta extends StatefulWidget {
  const PantallaDeDetalleDeVenta({super.key, required this.ventaId});

  final String ventaId;

  @override
  State<PantallaDeDetalleDeVenta> createState() =>
      _EstadoDePantallaDeDetalleDeVenta();
}

class _EstadoDePantallaDeDetalleDeVenta
    extends State<PantallaDeDetalleDeVenta> {
  /// Cambia cada vez que la venta se edita o se cancela, para que se
  /// vuelva a pedir al servidor.
  int _version = 0;

  Future<void> _editar(Venta venta) async {
    await abrirPantalla(context, PantallaDeEditarVenta(venta: venta));
    if (mounted) setState(() => _version++);
  }

  Future<void> _cancelar(Venta venta) async {
    final dependencias = Dependencias.de(context);

    final confirmo = await pedirConfirmacion(
      context,
      titulo: '¿Cancelar esta venta?',
      mensaje:
          'No se borra: deja de contar en la caja y en los reportes. No se '
          'puede deshacer.',
      textoDeConfirmar: 'Cancelar venta',
    );
    if (!confirmo) return;

    try {
      await dependencias.conexiones.ventas.cancelarVenta(venta.id);
      // El aviso de "Venta registrada" ya no dice la verdad.
      dependencias.ventas.cerrarAviso();
      if (mounted) setState(() => _version++);
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo cancelar la venta',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repositorio = Dependencias.de(context).conexiones.ventas;

    return MarcoDePantalla(
      child: CargadorDeFuturo<Venta>(
        key: ValueKey(_version),
        cargar: () => repositorio.obtenerVenta(widget.ventaId),
        construir: (context, venta) => _construirVenta(venta),
      ),
    );
  }

  Widget _construirVenta(Venta venta) {
    final sesion = Dependencias.de(context).sesion;

    return ColumnaConPie(
      espacio: 14,
      pie: _construirPie(venta),
      children: [
        EncabezadoConVolver(
          titulo: 'Venta de las ${formatearHora(venta.creadaEn)}',
          subtitulo: _subtitulo(venta, sesion),
        ),
        if (venta.estaCancelada)
          const BandaDeAviso(
            colores: Colores.alerta,
            titulo: 'Venta cancelada: no cuenta en la caja ni en los reportes',
          ),
        TarjetaDePedido(
          tamanoDeTotal: 44,
          total: venta.total,
          renglones: [
            for (final linea in venta.lineas)
              (
                concepto: '${linea.cantidad} × ${linea.nombreCompleto}',
                subtotal: linea.subtotal,
              ),
          ],
        ),
        TarjetaDePagoYNota(venta: venta),
        if (venta.eventos.isNotEmpty) HistorialDeVenta(eventos: venta.eventos),
      ],
    );
  }

  /// "Jueves 6 de noviembre · la registró Mari"
  String _subtitulo(Venta venta, Sesion sesion) {
    final fecha = formatearFechaLarga(venta.creadaEn);
    return '$fecha · la registró ${sesion.nombreDe(venta.perfilId)}';
  }

  Widget _construirPie(Venta venta) {
    // `sePuedeCambiar` lo decide el servidor: considera que seas la dueña,
    // que la venta no esté cancelada y que su caja siga abierta.
    if (!venta.sePuedeCambiar) {
      return const TextoDeAyuda(
        'Una venta solo se puede editar o cancelar mientras la caja de su '
        'día siga abierta.',
        centrado: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        const TextoDeAyuda(
          'Solo tú puedes editar o cancelar, y solo mientras la caja de '
          'este día siga abierta. Una venta cancelada no se borra: deja de '
          'contar en la caja y en los reportes.',
        ),
        BotonDeContorno(
          texto: 'Editar venta',
          icono: Icons.edit_outlined,
          alTocar: () => _editar(venta),
        ),
        Center(
          child: BotonDeEnlace(
            texto: 'Cancelar venta',
            alTocar: () => _cancelar(venta),
          ),
        ),
      ],
    );
  }
}
