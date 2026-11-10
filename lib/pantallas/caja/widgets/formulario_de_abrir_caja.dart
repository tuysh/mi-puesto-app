import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/pantallas/caja/widgets/campo_de_dinero.dart';

/// Lo que se ve en "Cerrar caja" cuando todavía no hay ninguna caja
/// abierta: se escribe con cuánto dinero se empieza y se abre.
class FormularioDeAbrirCaja extends StatefulWidget {
  const FormularioDeAbrirCaja({super.key, required this.alAbrir});

  /// Se llama cuando la caja quedó abierta.
  final VoidCallback alAbrir;

  @override
  State<FormularioDeAbrirCaja> createState() =>
      _EstadoDeFormularioDeAbrirCaja();
}

class _EstadoDeFormularioDeAbrirCaja extends State<FormularioDeAbrirCaja> {
  final _controladorDeFondo = TextEditingController();

  bool _abriendo = false;

  @override
  void dispose() {
    _controladorDeFondo.dispose();
    super.dispose();
  }

  Future<void> _abrirCaja() async {
    // Dejar el campo vacío es abrir sin dinero para dar cambio.
    final texto = _controladorDeFondo.text.trim();
    final fondo = texto.isEmpty ? Dinero.cero : leerDinero(texto);
    if (fondo == null) {
      mostrarAviso(context, 'Escribe con cuánto dinero abres la caja');
      return;
    }

    final repositorio = Dependencias.de(context).conexiones.caja;
    setState(() => _abriendo = true);
    try {
      await repositorio.abrirCaja(fondo);
      if (!mounted) return;

      mostrarAviso(context, 'Caja abierta');
      widget.alAbrir();
    } catch (error) {
      if (!mounted) return;

      mostrarAvisoDeError(
        context,
        error,
        siNoHayExplicacion: 'No se pudo abrir la caja',
      );
      setState(() => _abriendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColumnaConPie(
      pie: BotonPrincipal(
        texto: 'Abrir caja',
        icono: Icons.lock_open_rounded,
        alTocar: _abriendo ? null : _abrirCaja,
      ),
      children: [
        Text('Todavía no has abierto la caja', style: Tipografia.titulo(24)),
        Text(
          'Ábrela para llevar la cuenta del efectivo. Las ventas en '
          'efectivo cuentan a partir de que la abres.',
          style: Tipografia.texto(
            16,
            peso: 600,
            color: Colores.tintaSuave,
            altura: 1.35,
          ),
        ),
        CampoEtiquetado(
          etiqueta: '¿Con cuánto dinero abres?',
          tamanoDeEtiqueta: 17,
          child: CampoDeDinero(
            controlador: _controladorDeFondo,
            alCambiar: (_) {},
          ),
        ),
      ],
    );
  }
}
