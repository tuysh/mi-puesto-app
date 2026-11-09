import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_texto.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/pantallas/caja/widgets/aviso_de_diferencia.dart';
import 'package:mi_puesto/pantallas/caja/widgets/campo_de_dinero.dart';
import 'package:mi_puesto/pantallas/caja/widgets/tarjeta_de_cuenta_de_caja.dart';

/// Lo que se llena para cerrar la caja: cuánto se contó y una nota opcional.
/// Mientras se escribe, avisa si falta o sobra dinero.
class FormularioDeCierre extends StatefulWidget {
  const FormularioDeCierre({super.key, required this.cuenta});

  final CuentaDeCaja cuenta;

  @override
  State<FormularioDeCierre> createState() => _EstadoDeFormularioDeCierre();
}

class _EstadoDeFormularioDeCierre extends State<FormularioDeCierre> {
  final _controladorDeContado = TextEditingController();
  final _controladorDeNota = TextEditingController();

  bool _cerrando = false;

  /// Lo que la persona contó; `null` si aún no escribe un número válido.
  Dinero? get _contado => leerDinero(_controladorDeContado.text);

  @override
  void dispose() {
    _controladorDeContado.dispose();
    _controladorDeNota.dispose();
    super.dispose();
  }

  Future<void> _cerrarCaja() async {
    final contado = _contado;
    if (contado == null) return;

    final repositorio = Dependencias.de(context).conexiones.caja;
    final cierre = CierreDeCaja(
      contado: contado,
      nota: _controladorDeNota.text.trim(),
    );

    setState(() => _cerrando = true);
    try {
      await repositorio.cerrarCaja(cierre);
      if (!mounted) return;

      mostrarAviso(context, 'Caja cerrada');
      cerrarPantalla(context);
    } catch (_) {
      if (!mounted) return;

      mostrarAviso(context, 'No se pudo cerrar la caja');
      setState(() => _cerrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contado = _contado;
    final sePuedeCerrar = contado != null && !_cerrando;

    return ColumnaConPie(
      pie: BotonPrincipal(
        texto: 'Cerrar caja de hoy',
        icono: Icons.lock_outline_rounded,
        alTocar: sePuedeCerrar ? _cerrarCaja : null,
      ),
      children: [
        TarjetaDeCuentaDeCaja(cuenta: widget.cuenta),
        CampoEtiquetado(
          etiqueta: '¿Cuánto contaste en la caja?',
          tamanoDeEtiqueta: 17,
          child: CampoDeDinero(
            controlador: _controladorDeContado,
            // Redibuja para recalcular la diferencia con cada tecla.
            alCambiar: (_) => setState(() {}),
          ),
        ),
        if (contado != null)
          AvisoDeDiferencia(diferencia: contado - widget.cuenta.debeHaber),
        CampoEtiquetado(
          etiqueta: 'Nota (opcional)',
          child: CampoDeTexto(
            controlador: _controladorDeNota,
            sugerencia: 'Ej. di cambio de más',
          ),
        ),
      ],
    );
  }
}
