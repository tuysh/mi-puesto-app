import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/vendedor.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/dialogo_de_texto.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';
import 'package:mi_puesto/pantallas/principal/pantalla_principal.dart';
import 'package:mi_puesto/pantallas/vendedores/widgets/cuadricula_de_vendedores.dart';

/// Pantalla 2: se elige quién va a vender. Cada venta queda a su nombre.
class PantallaQuienVende extends StatefulWidget {
  const PantallaQuienVende({super.key});

  @override
  State<PantallaQuienVende> createState() => _EstadoDePantallaQuienVende();
}

class _EstadoDePantallaQuienVende extends State<PantallaQuienVende> {
  /// Cambia cada vez que se agrega una persona, para que la lista se
  /// vuelva a pedir al repositorio.
  int _versionDeLaLista = 0;

  void _elegir(Vendedor vendedor) {
    Dependencias.de(context).sesion.elegirVendedor(vendedor);
    reemplazarTodasLasPantallas(context, const PantallaPrincipal());
  }

  Future<void> _agregarPersona() async {
    final repositorio = Dependencias.de(context).conexiones.vendedores;

    final nombre = await pedirTexto(
      context,
      titulo: 'Agregar persona',
      sugerencia: 'Nombre',
    );
    if (nombre == null) return;

    try {
      await repositorio.agregarVendedor(nombre);
      setState(() => _versionDeLaLista++);
    } catch (_) {
      if (mounted) mostrarAviso(context, 'No se pudo agregar a la persona');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dependencias = Dependencias.de(context);

    return Scaffold(
      body: SafeArea(
        child: AnchoMaximo(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EncabezadoDePantalla(
                  sobretitulo: dependencias.sesion.nombreDelPuesto,
                  titulo: '¿Quién vende hoy?',
                  tamanoDeTitulo: 34,
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: CargadorDeFuturo<List<Vendedor>>(
                    key: ValueKey(_versionDeLaLista),
                    cargar:
                        dependencias.conexiones.vendedores.obtenerVendedores,
                    construir: (context, vendedores) => CuadriculaDeVendedores(
                      vendedores: vendedores,
                      alElegir: _elegir,
                      alAgregar: _agregarPersona,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cada venta queda a nombre de quien la registró',
                  textAlign: TextAlign.center,
                  style: Tipografia.texto(
                    15,
                    peso: 600,
                    color: Colores.tintaSuave,
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
