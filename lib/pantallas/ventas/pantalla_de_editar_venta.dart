import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/cifra_con_doble_raya.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/nucleo/widgets/linea_punteada.dart';
import 'package:mi_puesto/nucleo/widgets/marco_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_elevada.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/campo_de_nota.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/selector_de_metodo_de_pago.dart';
import 'package:mi_puesto/pantallas/vender/widgets/renglon_de_pedido.dart';

/// Corrige una venta ya registrada: cuántas piezas de cada producto, cómo
/// se pagó y la nota. Se ve como la pantalla "Pedido".
///
/// Los renglones conservan el precio con el que se cobraron. Dejar un
/// renglón en cero lo quita de la venta.
///
/// PENDIENTE: aquí no se pueden agregar productos que la venta no tenía.
class PantallaDeEditarVenta extends StatefulWidget {
  const PantallaDeEditarVenta({super.key, required this.venta});

  final Venta venta;

  @override
  State<PantallaDeEditarVenta> createState() =>
      _EstadoDePantallaDeEditarVenta();
}

class _EstadoDePantallaDeEditarVenta extends State<PantallaDeEditarVenta> {
  /// Los renglones como van quedando. Los que llegan a cero se quedan en
  /// la lista (en cero) para poder arrepentirse; al guardar no se mandan.
  late final List<LineaDeVenta> _lineas = [...widget.venta.lineas];

  late MetodoDePago _metodo = widget.venta.metodoDePago;
  late final _nota = TextEditingController(text: widget.venta.nota);

  bool _guardando = false;

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  Dinero get _total => sumarDinero(_lineas.map((linea) => linea.subtotal));

  /// Suma [piezas] al renglón que está en [posicion] (o resta, si es
  /// negativo). Nunca baja de cero.
  void _sumar(int posicion, int piezas) {
    final cantidad = _lineas[posicion].cantidad + piezas;
    if (cantidad < 0) return;

    setState(() {
      _lineas[posicion] = _lineas[posicion].conCantidad(cantidad);
    });
  }

  Future<void> _guardar() async {
    final lineasQueQuedan = [
      for (final linea in _lineas)
        if (linea.cantidad > 0) linea,
    ];
    if (lineasQueQuedan.isEmpty) {
      mostrarAviso(
        context,
        'Una venta no puede quedar sin productos. Si no se hizo, cancélala',
      );
      return;
    }

    final repositorio = Dependencias.de(context).conexiones.ventas;
    final avisoDeVenta = Dependencias.de(context).ventas;
    setState(() => _guardando = true);
    try {
      await repositorio.editarVenta(
        widget.venta.id,
        // `lineas` es el pedido completo, no solo lo que cambió.
        lineas: [
          for (final linea in lineasQueQuedan)
            LineaPorCobrar(
              productoId: linea.productoId,
              presentacionId: linea.presentacionId,
              cantidad: linea.cantidad,
            ),
        ],
        metodoDePago: _metodo,
        nota: _nota.text.trim(),
      );
      // El aviso de "Venta registrada" ya no dice la verdad.
      avisoDeVenta.cerrarAviso();
      if (!mounted) return;

      cerrarPantalla(context);
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo guardar la venta',
        );
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MarcoDePantalla(
      child: ColumnaConPie(
        espacio: 14,
        pie: BotonPrincipal(
          texto: 'Guardar cambios',
          icono: Icons.check_rounded,
          iconoAlFinal: true,
          alTocar: _guardando ? null : _guardar,
        ),
        children: [
          const EncabezadoConVolver(titulo: 'Editar venta'),
          TarjetaElevada(
            relleno: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (posicion, linea) in _lineas.indexed) ...[
                  _construirRenglon(posicion, linea),
                  const LineaPunteada(),
                ],
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: Tipografia.texto(18, peso: 800)),
                    CifraConDobleRaya(formatearDinero(_total), tamano: 44),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text('¿Cómo pagó?', style: Tipografia.texto(17, peso: 800)),
              SelectorDeMetodoDePago(
                elegido: _metodo,
                alElegir: (metodo) => setState(() => _metodo = metodo),
              ),
            ],
          ),
          CampoDeNota(controlador: _nota),
          const TextoDeAyuda(
            'Cada producto conserva el precio con el que se cobró.',
          ),
        ],
      ),
    );
  }

  Widget _construirRenglon(int posicion, LineaDeVenta linea) {
    final catalogo = Dependencias.de(context).catalogo;
    // El producto pudo desactivarse después de la venta: entonces ya no
    // está en el catálogo y el renglón va sin imagen.
    final producto = catalogo.buscarProducto(linea.productoId);

    final precio = '${formatearDinero(linea.precioUnitario)} c/u';
    final tamano = linea.nombreDelTamano;

    return RenglonDePedido(
      imagen: producto == null
          ? null
          : ImagenDeProducto.de(
              producto,
              colores: catalogo.coloresDe(producto.categoriaId),
              tamano: 40,
            ),
      nombre: linea.nombreDelProducto,
      detalle: tamano.isEmpty ? precio : '$tamano · $precio',
      cantidad: linea.cantidad,
      nombreParaLeer: linea.nombreCompleto,
      alQuitar: () => _sumar(posicion, -1),
      alAgregar: () => _sumar(posicion, 1),
    );
  }
}
