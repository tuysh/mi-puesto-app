import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/fila_de_lista.dart';
import 'package:mi_puesto/nucleo/widgets/lista_en_tarjeta.dart';
import 'package:mi_puesto/pantallas/acceso/cerrar_sesion.dart';
import 'package:mi_puesto/pantallas/caja/pantalla_de_cierres.dart';
import 'package:mi_puesto/pantallas/categorias/pantalla_de_categorias.dart';
import 'package:mi_puesto/pantallas/gastos/pantalla_de_gastos.dart';
import 'package:mi_puesto/pantallas/personas/pantalla_de_personas.dart';
import 'package:mi_puesto/pantallas/productos/pantalla_de_productos.dart';
import 'package:mi_puesto/pantallas/ventas/pantalla_de_ventas_del_dia.dart';

/// Pantalla 5.1: el menú de todo lo que no es vender. Solo la dueña ve
/// esta pestaña.
class PantallaMas extends StatelessWidget {
  const PantallaMas({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = Dependencias.de(context).sesion;

    // Scaffold propio: en tablet esta pantalla vive en su propio navegador
    // y necesita su fondo.
    return Scaffold(
      body: AnchoMaximo(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
          child: ColumnaConPie(
            espacio: 14,
            pie: BotonDeContorno(
              texto: 'Cerrar sesión',
              icono: Icons.logout_rounded,
              alTocar: () => cerrarSesion(context),
            ),
            children: [
              EncabezadoDePantalla(
                sobretitulo: sesion.nombreDelNegocio,
                titulo: 'Más',
              ),
              ListaEnTarjeta(
                children: [
                  _construirOpcion(
                    context,
                    titulo: 'Ventas del día',
                    detalle: 'Ver, editar o cancelar una venta',
                    pantalla: const PantallaDeVentasDelDia(),
                  ),
                  _construirOpcion(
                    context,
                    titulo: 'Gastos',
                    detalle: 'Anotar y consultar gastos',
                    pantalla: const PantallaDeGastos(),
                  ),
                  _construirOpcion(
                    context,
                    titulo: 'Cierres anteriores',
                    detalle: 'Cómo cerró la caja cada día',
                    pantalla: const PantallaDeCierres(),
                  ),
                  _construirOpcion(
                    context,
                    titulo: 'Productos',
                    detalle: 'Precios, tamaños y qué hay hoy',
                    pantalla: const PantallaDeProductos(),
                  ),
                  _construirOpcion(
                    context,
                    titulo: 'Categorías',
                    detalle: 'De productos y de gastos',
                    pantalla: const PantallaDeCategorias(),
                  ),
                  _construirOpcion(
                    context,
                    titulo: 'Personas',
                    detalle: 'Quién vende y sus PIN',
                    pantalla: const PantallaDePersonas(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirOpcion(
    BuildContext context, {
    required String titulo,
    required String detalle,
    required Widget pantalla,
  }) {
    return FilaDeLista(
      titulo: titulo,
      detalle: detalle,
      altoMinimo: 68,
      tamanoDeTitulo: 17,
      alTocar: () => abrirPantalla(context, pantalla),
    );
  }
}
