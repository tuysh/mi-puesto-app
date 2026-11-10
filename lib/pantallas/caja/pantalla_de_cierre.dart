import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/pantallas/caja/widgets/formulario_de_abrir_caja.dart';
import 'package:mi_puesto/pantallas/caja/widgets/formulario_de_cierre.dart';

/// Pantalla 8: al final del día se cuenta el dinero de la caja y se compara
/// con lo que debería haber. Si todavía no hay caja abierta, aquí mismo
/// se abre.
class PantallaDeCierre extends StatefulWidget {
  const PantallaDeCierre({super.key});

  @override
  State<PantallaDeCierre> createState() => _EstadoDePantallaDeCierre();
}

class _EstadoDePantallaDeCierre extends State<PantallaDeCierre> {
  /// Cambia al abrir la caja, para que la cuenta se vuelva a pedir al
  /// repositorio.
  int _versionDeLaCuenta = 0;

  @override
  Widget build(BuildContext context) {
    final repositorio = Dependencias.de(context).conexiones.caja;

    return Scaffold(
      body: SafeArea(
        child: AnchoMaximo(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                EncabezadoConVolver(
                  titulo: 'Cerrar caja',
                  subtitulo: formatearFechaLarga(DateTime.now()),
                ),
                Expanded(
                  child: CargadorDeFuturo<CuentaDeCaja?>(
                    key: ValueKey(_versionDeLaCuenta),
                    cargar: repositorio.obtenerCuentaDeCaja,
                    construir: (context, cuenta) {
                      // `null` quiere decir que no hay caja abierta.
                      if (cuenta == null) {
                        return FormularioDeAbrirCaja(
                          alAbrir: () => setState(() => _versionDeLaCuenta++),
                        );
                      }
                      return FormularioDeCierre(cuenta: cuenta);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
