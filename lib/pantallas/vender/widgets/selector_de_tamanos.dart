import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/presentacion.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/imagen_de_producto.dart';
import 'package:mi_puesto/nucleo/widgets/lista_en_tarjeta.dart';
import 'package:mi_puesto/pantallas/vender/widgets/renglon_de_tamano.dart';

/// El contenido de "¿De qué tamaño?": un renglón por tamaño para decir
/// cuántas piezas van de cada uno, y los botones para terminar.
///
/// Elegir tamaño es obligatorio: cada tamaño entra al pedido como su
/// propio renglón. Las cantidades se guardan aquí y solo pasan al pedido
/// al tocar "Agregar".
class SelectorDeTamanos extends StatefulWidget {
  const SelectorDeTamanos({
    super.key,
    required this.producto,
    required this.colores,
  });

  final Producto producto;

  /// Los colores de la categoría del producto.
  final ParDeColores colores;

  @override
  State<SelectorDeTamanos> createState() => _EstadoDeSelectorDeTamanos();
}

class _EstadoDeSelectorDeTamanos extends State<SelectorDeTamanos> {
  /// Cuántas piezas van de cada tamaño, por el `id` del tamaño.
  final Map<String, int> _cantidades = {};

  @override
  void initState() {
    super.initState();

    // Empieza con lo que el pedido ya lleva de este producto.
    final pedido = Dependencias.de(context).pedido;
    for (final presentacion in widget.producto.presentaciones) {
      _cantidades[presentacion.id] = pedido.cantidadDe(
        widget.producto,
        presentacion: presentacion,
      );
    }
  }

  int _cantidadDe(Presentacion presentacion) => _cantidades[presentacion.id]!;

  /// Suma [piezas] a lo que va de ese tamaño (o resta, si es negativo).
  /// Nunca baja de cero.
  void _sumar(Presentacion presentacion, int piezas) {
    final cantidad = _cantidadDe(presentacion) + piezas;
    if (cantidad < 0) return;

    setState(() => _cantidades[presentacion.id] = cantidad);
  }

  int get _piezas {
    return _cantidades.values.fold(0, (suma, cantidad) => suma + cantidad);
  }

  Dinero get _monto {
    return sumarDinero([
      for (final presentacion in widget.producto.presentaciones)
        presentacion.precio * _cantidadDe(presentacion),
    ]);
  }

  /// Pasa las cantidades al pedido y cierra la hoja.
  void _agregar() {
    final pedido = Dependencias.de(context).pedido;
    for (final presentacion in widget.producto.presentaciones) {
      pedido.ponerCantidad(
        widget.producto,
        _cantidadDe(presentacion),
        presentacion: presentacion,
      );
    }
    cerrarPantalla(context);
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final piezas = _piezas;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            spacing: 14,
            children: [
              ImagenDeProducto.de(
                producto,
                colores: widget.colores,
                tamano: 60,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text('¿De qué tamaño?', style: Tipografia.titulo(24)),
                    Text(
                      producto.nombre,
                      style: Tipografia.texto(
                        15,
                        peso: 600,
                        color: Colores.tintaSuave,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ListaEnTarjeta(
            children: [
              for (final presentacion in producto.presentaciones)
                RenglonDeTamano(
                  nombre: presentacion.nombre,
                  precio: formatearDinero(presentacion.precio),
                  colorDelPrecio: widget.colores.tinta,
                  cantidad: _cantidadDe(presentacion),
                  nombreParaLeer: unirNombreYTamano(
                    producto.nombre,
                    presentacion.nombre,
                  ),
                  alQuitar: () => _sumar(presentacion, -1),
                  alAgregar: () => _sumar(presentacion, 1),
                ),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              BotonDeContorno(
                texto: 'Cancelar',
                alTocar: () => cerrarPantalla(context),
              ),
              Expanded(
                child: BotonPrincipal(
                  texto: piezas == 0
                      ? 'Elige al menos uno'
                      : 'Agregar $piezas · ${formatearDinero(_monto)}',
                  alto: 56,
                  tamanoDeTexto: 20,
                  // Si el pedido ya llevaba piezas, dejar todo en cero
                  // también vale: es la manera de quitarlas desde aquí.
                  alTocar: piezas == 0 && !_elPedidoYaLlevaba ? null : _agregar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool get _elPedidoYaLlevaba {
    return Dependencias.de(context).pedido.piezasDe(widget.producto) > 0;
  }
}
