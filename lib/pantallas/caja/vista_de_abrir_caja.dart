import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_dinero.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';

/// Pantalla 2.1: lo que ve la dueña en "Vender" mientras la caja está
/// cerrada. Escribe con cuánto dinero abre y la abre.
///
/// No cambia de pantalla al terminar: cuando la caja se abre, "Vender" se
/// redibuja solo y muestra los productos.
class VistaDeAbrirCaja extends StatefulWidget {
  const VistaDeAbrirCaja({super.key});

  @override
  State<VistaDeAbrirCaja> createState() => _EstadoDeVistaDeAbrirCaja();
}

class _EstadoDeVistaDeAbrirCaja extends State<VistaDeAbrirCaja> {
  final _fondo = TextEditingController();

  bool _abriendo = false;

  @override
  void dispose() {
    _fondo.dispose();
    super.dispose();
  }

  Future<void> _abrir() async {
    // Dejar el campo vacío es abrir sin cambio: con cero.
    final texto = _fondo.text.trim();
    final fondo = leerDinero(texto.isEmpty ? '0' : texto);
    if (fondo == null) {
      mostrarAviso(context, 'Escribe solo el número, por ejemplo 500');
      return;
    }

    final caja = Dependencias.de(context).caja;
    setState(() => _abriendo = true);
    try {
      await caja.abrir(fondo);
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo abrir la caja',
        );
      }
    } finally {
      if (mounted) setState(() => _abriendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnchoMaximo(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
        child: ColumnaConPie(
          espacio: 18,
          pie: BotonPrincipal(
            texto: 'Abrir caja',
            alTocar: _abriendo ? null : _abrir,
          ),
          children: [
            EncabezadoDePantalla(
              sobretitulo: formatearFechaLarga(DateTime.now()),
              titulo: 'Abre la caja para empezar',
              tamanoDeTitulo: 34,
            ),
            CampoEtiquetado(
              etiqueta: '¿Con cuánto dinero abres?',
              tamanoDeEtiqueta: 17,
              child: CampoDeDinero(controlador: _fondo),
            ),
            const TextoDeAyuda(
              'Es el cambio con el que empiezas el día. Mientras la caja '
              'esté cerrada, nadie puede registrar ventas.',
              tamano: 15,
            ),
          ],
        ),
      ),
    );
  }
}
