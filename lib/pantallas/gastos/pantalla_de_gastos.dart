import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/gasto.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/fechas.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_fecha.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/fila_de_lista.dart';
import 'package:mi_puesto/nucleo/widgets/fila_de_lista_vacia.dart';
import 'package:mi_puesto/nucleo/widgets/filtro_de_categorias.dart';
import 'package:mi_puesto/nucleo/widgets/lista_en_tarjeta.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/resumen_de_lista.dart';
import 'package:mi_puesto/pantallas/gastos/pantalla_de_gasto.dart';

/// Pantalla 4.1: los gastos de un rango de fechas (al abrir, la semana en
/// curso), que se pueden filtrar por categoría. Desde aquí se anota uno
/// nuevo o se toca uno para cambiarlo.
class PantallaDeGastos extends StatefulWidget {
  const PantallaDeGastos({super.key});

  @override
  State<PantallaDeGastos> createState() => _EstadoDePantallaDeGastos();
}

class _EstadoDePantallaDeGastos extends State<PantallaDeGastos> {
  DateTime _desde = lunesDe(hoy());
  DateTime _hasta = domingoDe(hoy());

  /// La categoría elegida en el filtro; `null` significa "Todas".
  String? _categoriaId;

  /// Cambia cada vez que se vuelve de anotar o editar un gasto, para que
  /// la lista se pida otra vez.
  int _version = 0;

  /// Las categorías de gastos, para el filtro y para decir de cuál es cada
  /// gasto. Vacía mientras llegan.
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  /// Las categorías se piden aparte de los gastos, una sola vez: así el
  /// filtro no se redibuja (ni pierde su lugar) cada vez que cambia la
  /// lista.
  Future<void> _cargarCategorias() async {
    final repositorio = Dependencias.de(context).conexiones.categoriasDeGastos;

    try {
      final categorias = await repositorio.obtenerCategorias();
      if (mounted) setState(() => _categorias = categorias);
    } catch (_) {
      // Sin categorías la pantalla sigue sirviendo, solo que sin filtro.
      // Si el problema es de conexión, la lista de abajo lo va a decir.
    }
  }

  Future<GastosDelPeriodo> _cargarGastos() {
    return Dependencias.de(context).conexiones.gastos
        .obtenerGastos(desde: _desde, hasta: _hasta, categoriaId: _categoriaId);
  }

  Future<void> _elegirFechas() async {
    final rango = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _desde, end: _hasta),
      firstDate: DateTime(2020),
      lastDate: sumarDias(hoy(), 366),
      helpText: '¿De qué fechas?',
      saveText: 'Listo',
    );
    if (rango == null) return;

    setState(() {
      _desde = rango.start;
      _hasta = rango.end;
    });
  }

  Future<void> _abrir(Gasto? gasto) async {
    if (gasto != null && !gasto.editable) {
      mostrarAviso(
        context,
        'Este gasto se pagó con una caja que ya se cerró: ya no se puede '
        'cambiar',
      );
      return;
    }

    await abrirPantalla(context, PantallaDeGasto(gasto: gasto));
    if (mounted) setState(() => _version++);
  }

  @override
  Widget build(BuildContext context) {
    return MarcoDePantalla(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          const EncabezadoConVolver(titulo: 'Gastos'),
          BotonDeFecha(
            texto: formatearRango(_desde, _hasta),
            alto: 48,
            conFlecha: true,
            alTocar: _elegirFechas,
          ),
          FiltroDeCategorias(
            categorias: _categorias,
            elegida: _categoriaId,
            textoDeTodas: 'Todas',
            enUnaSolaFila: true,
            alElegir: (categoriaId) =>
                setState(() => _categoriaId = categoriaId),
          ),
          Expanded(
            child: CargadorDeFuturo<GastosDelPeriodo>(
              // Con otra llave se vuelve a pedir: otras fechas, otra
              // categoría u otra versión.
              key: ValueKey((_desde, _hasta, _categoriaId, _version)),
              cargar: _cargarGastos,
              construir: (context, gastos) => _construirLista(gastos),
            ),
          ),
          BotonPrincipal(
            texto: 'Anotar gasto',
            icono: Icons.add_rounded,
            alTocar: () => _abrir(null),
          ),
        ],
      ),
    );
  }

  Widget _construirLista(GastosDelPeriodo periodo) {
    final cuantos = periodo.gastos.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        ResumenDeLista(
          texto: '$cuantos ${cuantos == 1 ? 'gasto' : 'gastos'}',
          total: formatearDinero(periodo.total),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: ListaEnTarjeta(
              children: [
                if (periodo.gastos.isEmpty)
                  const FilaDeListaVacia('No hay gastos en estas fechas.'),
                for (final gasto in periodo.gastos)
                  FilaDeLista(
                    altoMinimo: 60,
                    titulo: gasto.concepto,
                    detalle: _detalleDe(gasto),
                    monto: formatearDinero(gasto.monto),
                    alTocar: () => _abrir(gasto),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// "Sáb 8 · Ingredientes · de la caja"
  String _detalleDe(Gasto gasto) {
    String? nombreDeCategoria;
    for (final categoria in _categorias) {
      if (categoria.id == gasto.categoriaId) {
        nombreDeCategoria = categoria.nombre;
      }
    }

    return [
      formatearDiaCorto(gasto.fecha),
      ?nombreDeCategoria,
      gasto.deCaja ? 'de la caja' : 'aparte',
    ].join(' · ');
  }
}
