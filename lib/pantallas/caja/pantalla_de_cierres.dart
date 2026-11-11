import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/fila_de_lista.dart';
import 'package:mi_puesto/nucleo/widgets/fila_de_lista_vacia.dart';
import 'package:mi_puesto/nucleo/widgets/lista_en_tarjeta.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/pastilla.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/caja/pantalla_de_cierre.dart';

/// Pantalla 3.7: los cierres de caja anteriores, del más nuevo al más
/// viejo. Solo consulta: la caja de hoy se cierra desde "Hoy".
class PantallaDeCierres extends StatefulWidget {
  const PantallaDeCierres({super.key});

  @override
  State<PantallaDeCierres> createState() => _EstadoDePantallaDeCierres();
}

class _EstadoDePantallaDeCierres extends State<PantallaDeCierres> {
  /// Los cierres que ya llegaron. El servidor los manda por páginas.
  final List<CierreResumido> _cierres = [];

  /// Con esto se pide la página que sigue; `null` si ya no hay más.
  String? _siguiente;

  bool _cargandoMas = false;

  Future<void> _cargarPrimeraPagina() async {
    final repositorio = Dependencias.de(context).conexiones.caja;
    _recibir(await repositorio.obtenerCierres());
  }

  Future<void> _cargarMas() async {
    final repositorio = Dependencias.de(context).conexiones.caja;

    setState(() => _cargandoMas = true);
    try {
      final pagina = await repositorio.obtenerCierres(antes: _siguiente);
      if (mounted) setState(() => _recibir(pagina));
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudieron cargar más cierres',
        );
      }
    } finally {
      if (mounted) setState(() => _cargandoMas = false);
    }
  }

  void _recibir(PaginaDeCierres pagina) {
    _cierres.addAll(pagina.cierres);
    _siguiente = pagina.siguiente;
  }

  Future<void> _abrir(CierreResumido cierre) async {
    final repositorio = Dependencias.de(context).conexiones.caja;

    try {
      final completo = await repositorio.obtenerCierre(cierre.id);
      if (!mounted) return;

      abrirPantalla(context, PantallaDeCierre(cierre: completo));
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo abrir ese cierre',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MarcoDePantalla(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          const EncabezadoConVolver(titulo: 'Cierres anteriores'),
          const TextoDeAyuda(
            'Lo que se vendió cada día y si la caja cuadró al cerrar.',
            peso: 700,
          ),
          Expanded(
            child: CargadorDeFuturo<void>(
              cargar: _cargarPrimeraPagina,
              construir: (context, _) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    ListaEnTarjeta(
                      children: [
                        if (_cierres.isEmpty)
                          const FilaDeListaVacia(
                            'Todavía no has cerrado ninguna caja.',
                          ),
                        for (final cierre in _cierres)
                          FilaDeLista(
                            altoMinimo: 68,
                            titulo: formatearFechaLarga(cierre.fecha),
                            bajoElTitulo: _pastillaDe(cierre.diferencia),
                            monto: formatearDinero(cierre.vendido),
                            alTocar: () => _abrir(cierre),
                          ),
                      ],
                    ),
                    if (_siguiente != null)
                      BotonDeContorno(
                        texto: 'Ver más antiguos',
                        alTocar: _cargandoMas ? null : _cargarMas,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Cuadró" en verde, o cuánto sobró o faltó en ámbar.
  Widget _pastillaDe(Dinero diferencia) {
    if (diferencia.esCero) {
      return const Pastilla.chica(texto: 'Cuadró', colores: Colores.exito);
    }

    final monto = formatearDinero(diferencia.absoluto);
    return Pastilla.chica(
      texto: diferencia.esNegativo ? 'Faltaron $monto' : 'Sobraron $monto',
      colores: Colores.alerta,
    );
  }
}
