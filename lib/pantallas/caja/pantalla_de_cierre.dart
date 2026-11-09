import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/pantallas/caja/widgets/formulario_de_cierre.dart';

/// Pantalla 8: al final del día se cuenta el dinero de la caja y se compara
/// con lo que debería haber.
class PantallaDeCierre extends StatelessWidget {
  const PantallaDeCierre({super.key});

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
                  child: CargadorDeFuturo<CuentaDeCaja>(
                    cargar: repositorio.obtenerCuentaDeCaja,
                    construir: (context, cuenta) {
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
