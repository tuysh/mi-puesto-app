import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/fechas.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_fecha.dart';
import 'package:mi_puesto/nucleo/widgets/ancho_maximo.dart';
import 'package:mi_puesto/nucleo/widgets/cargador_de_futuro.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/fila_de_lista.dart';
import 'package:mi_puesto/nucleo/widgets/fila_de_lista_vacia.dart';
import 'package:mi_puesto/nucleo/widgets/lista_en_tarjeta.dart';
import 'package:mi_puesto/nucleo/widgets/resumen_de_lista.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/principal/widgets/pastilla_de_persona.dart';
import 'package:mi_puesto/pantallas/ventas/widgets/marca_de_venta.dart';

/// Pantalla 3.4: lo que ve quien solo vende en su segunda pestaña: nada
/// más que las ventas que registró hoy esa persona. No puede editarlas ni
/// cancelarlas.
class PantallaMisVentas extends StatelessWidget {
  const PantallaMisVentas({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencias = Dependencias.de(context);
    final duena = dependencias.sesion.duena?.nombre ?? 'la dueña';

    return AnchoMaximo(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              children: [
                Expanded(
                  child: EncabezadoDePantalla(
                    sobretitulo: formatearFechaLarga(DateTime.now()),
                    titulo: 'Mis ventas',
                  ),
                ),
                const PastillaDePersona(),
              ],
            ),
            Expanded(
              child: CargadorDeFuturo<VentasDelDia>(
                // El servidor ya manda solo las ventas de quien pregunta.
                cargar: () =>
                    dependencias.conexiones.ventas.obtenerVentasDelDia(hoy()),
                construir: (context, ventasDelDia) => SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      ResumenDeLista(
                        texto: _textoDeCuantas(ventasDelDia.cuantas),
                        total: formatearDinero(ventasDelDia.total),
                      ),
                      ListaEnTarjeta(
                        children: [
                          if (ventasDelDia.ventas.isEmpty)
                            const FilaDeListaVacia(
                              'Todavía no registras ventas hoy.',
                            ),
                          for (final venta in ventasDelDia.ventas)
                            FilaDeLista(
                              titulo:
                                  '${formatearHora(venta.creadaEn)} · '
                                  '${venta.metodoDePago.etiqueta}',
                              juntoAlTitulo: MarcaDeVenta.haceFaltaPara(venta)
                                  ? MarcaDeVenta(venta: venta)
                                  : null,
                              detalle: _productosDe(venta),
                              monto: formatearDinero(venta.total),
                              montoTachado: venta.estaCancelada,
                            ),
                        ],
                      ),
                      TextoDeAyuda(
                        '¿Te equivocaste en una venta? Pídele a $duena que '
                        'la corrija.',
                        centrado: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _textoDeCuantas(int cuantas) {
    if (cuantas == 1) return '1 venta que registraste hoy';
    return '$cuantas ventas que registraste hoy';
  }

  /// "1 pay limón, 2 esquite"
  String _productosDe(Venta venta) {
    return [
      for (final linea in venta.lineas)
        '${linea.cantidad} ${linea.nombreCompleto.toLowerCase()}',
    ].join(', ');
  }
}
