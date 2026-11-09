import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/pantallas/hoy/pantalla_hoy.dart';
import 'package:mi_puesto/pantallas/mas/pantalla_de_historial.dart';
import 'package:mi_puesto/pantallas/mas/pantalla_mas.dart';
import 'package:mi_puesto/pantallas/principal/destino.dart';
import 'package:mi_puesto/pantallas/principal/widgets/barra_de_navegacion.dart';
import 'package:mi_puesto/pantallas/principal/widgets/riel_de_navegacion.dart';
import 'package:mi_puesto/pantallas/productos/pantalla_de_productos.dart';
import 'package:mi_puesto/pantallas/reportes/pantalla_de_reportes.dart';
import 'package:mi_puesto/pantallas/vender/pantalla_vender.dart';

/// El marco de la aplicación una vez dentro: el menú de navegación y,
/// junto a él, la sección elegida.
///
/// En teléfono el menú es una barra abajo; en tablet, un riel a la izquierda.
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _EstadoDePantallaPrincipal();
}

class _EstadoDePantallaPrincipal extends State<PantallaPrincipal> {
  Destino _destino = Destino.vender;

  @override
  void initState() {
    super.initState();
    Dependencias.de(context).catalogo.cargar();
  }

  void _irA(Destino destino) {
    setState(() => _destino = destino);
  }

  @override
  Widget build(BuildContext context) {
    final seccion = _construirSeccion();

    if (esTablet(context)) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              RielDeNavegacion(destinoActual: _destino, alElegir: _irA),
              Expanded(child: seccion),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(bottom: false, child: seccion),
      bottomNavigationBar: BarraDeNavegacion(
        destinoActual: _destino,
        alElegir: _irA,
      ),
    );
  }

  Widget _construirSeccion() {
    return switch (_destino) {
      Destino.vender => const PantallaVender(),
      Destino.hoy => const PantallaHoy(),
      Destino.reportes => const PantallaDeReportes(),
      Destino.historial => const PantallaDeHistorial(),
      Destino.productos => const PantallaDeProductos(),
      Destino.mas => PantallaMas(alElegir: _irA),
    };
  }
}
