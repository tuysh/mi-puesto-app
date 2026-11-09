import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/resumen_del_dia.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';
import 'package:mi_puesto/pantallas/caja/pantalla_de_cierre.dart';
import 'package:mi_puesto/pantallas/hoy/widgets/seccion_de_mas_vendidos.dart';
import 'package:mi_puesto/pantallas/hoy/widgets/seccion_de_quien_vendio.dart';
import 'package:mi_puesto/pantallas/hoy/widgets/tarjeta_de_dato.dart';
import 'package:mi_puesto/pantallas/hoy/widgets/tarjeta_de_vendido_hoy.dart';

/// Pantalla 6: cómo va el día. Cuánto se ha vendido, qué se vende más y
/// quién ha vendido; desde aquí se cierra la caja.
class PantallaHoy extends StatelessWidget {
  const PantallaHoy({super.key});

  @override
  Widget build(BuildContext context) {
    final repositorio = Dependencias.de(context).conexiones.reportes;

    return AnchoMaximo(
      child: CargadorDeFuturo<ResumenDelDia>(
        cargar: repositorio.obtenerResumenDeHoy,
        construir: (context, resumen) => _ContenidoDeHoy(resumen: resumen),
      ),
    );
  }
}

class _ContenidoDeHoy extends StatelessWidget {
  const _ContenidoDeHoy({required this.resumen});

  final ResumenDelDia resumen;

  static const _espacio = SizedBox(height: 14);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
      children: [
        EncabezadoDePantalla(
          sobretitulo: formatearFechaLarga(resumen.fecha),
          titulo: 'Hoy',
        ),
        _espacio,
        TarjetaDeVendidoHoy(vendido: resumen.vendido),
        const SizedBox(height: 10),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: TarjetaDeDato(
                etiqueta: 'Ganancia',
                valor: formatearDinero(resumen.ganancia),
                colores: Colores.exito,
              ),
            ),
            Expanded(
              child: TarjetaDeDato(
                etiqueta: 'Ventas',
                valor: '${resumen.numeroDeVentas}',
              ),
            ),
          ],
        ),
        _espacio,
        SeccionDeMasVendidos(masVendidos: resumen.masVendidos),
        _espacio,
        SeccionDeQuienVendio(ventas: resumen.ventasPorVendedor),
        _espacio,
        BotonDeContorno(
          texto: 'Cerrar caja del día',
          icono: Icons.lock_outline_rounded,
          alTocar: () => abrirPantalla(context, const PantallaDeCierre()),
        ),
      ],
    );
  }
}
