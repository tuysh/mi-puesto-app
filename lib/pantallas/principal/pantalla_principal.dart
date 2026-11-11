import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/pantallas/hoy/pantalla_hoy.dart';
import 'package:mi_puesto/pantallas/mas/pantalla_mas.dart';
import 'package:mi_puesto/pantallas/principal/destino.dart';
import 'package:mi_puesto/pantallas/principal/widgets/barra_de_navegacion.dart';
import 'package:mi_puesto/pantallas/principal/widgets/riel_de_navegacion.dart';
import 'package:mi_puesto/pantallas/reportes/pantalla_de_reportes.dart';
import 'package:mi_puesto/pantallas/vender/pantalla_vender.dart';
import 'package:mi_puesto/pantallas/ventas/pantalla_mis_ventas.dart';

/// El marco de la aplicación una vez dentro: el menú de navegación y,
/// junto a él, la sección elegida.
///
/// En teléfono el menú es una barra abajo; en tablet, un riel a la
/// izquierda. La dueña ve cuatro secciones; quien solo vende, dos.
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _EstadoDePantallaPrincipal();
}

class _EstadoDePantallaPrincipal extends State<PantallaPrincipal> {
  Destino _destino = Destino.vender;

  /// En tablet, "Más" tiene su propio navegador: así las pantallas que se
  /// abren desde ahí (Productos, Gastos…) quedan junto al riel en vez de
  /// taparlo. Con esta llave se puede regresar a su inicio.
  final _navegadorDeMas = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    final dependencias = Dependencias.de(context);
    dependencias.catalogo.cargar();
    dependencias.caja.cargar();
  }

  void _irA(Destino destino) {
    // Tocar "Más" estando ya en "Más" regresa a su menú.
    if (destino == Destino.mas && _destino == Destino.mas) {
      _navegadorDeMas.currentState?.popUntil((ruta) => ruta.isFirst);
    }
    setState(() => _destino = destino);
  }

  @override
  Widget build(BuildContext context) {
    final esDuena = Dependencias.de(context).sesion.esDuena;
    final destinos = esDuena ? destinosDeLaDuena : destinosDeQuienVende;

    if (esTablet(context)) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              RielDeNavegacion(
                destinos: destinos,
                destinoActual: _destino,
                alElegir: _irA,
              ),
              Expanded(child: _construirSeccion(enTablet: true)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(bottom: false, child: _construirSeccion(enTablet: false)),
      bottomNavigationBar: BarraDeNavegacion(
        destinos: destinos,
        destinoActual: _destino,
        alElegir: _irA,
      ),
    );
  }

  Widget _construirSeccion({required bool enTablet}) {
    return switch (_destino) {
      Destino.vender => const PantallaVender(),
      Destino.hoy => const PantallaHoy(),
      Destino.reportes => const PantallaDeReportes(),
      Destino.misVentas => const PantallaMisVentas(),
      Destino.mas =>
        enTablet
            ? Navigator(
                key: _navegadorDeMas,
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (context) => const PantallaMas(),
                ),
              )
            : const PantallaMas(),
    };
  }
}
