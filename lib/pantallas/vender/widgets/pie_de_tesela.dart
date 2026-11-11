import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Lo que dice el renglón de abajo de una tesela en teléfono.
enum EstadoDeTesela {
  /// "Toca para agregar", con un "+".
  paraAgregar,

  /// "Elegir tamaño", con una flechita: tocarla abre la hoja de tamaños.
  paraElegirTamano,

  /// "Hoy no hay": la tesela está apagada y no lleva icono.
  noHay,
}

/// El renglón de abajo de una tesela en teléfono.
///
/// Sin piezas en el pedido dice qué pasa al tocar (ver [EstadoDeTesela]).
/// Con piezas dice cuántas van ("2 en cuenta"). A la derecha hay un icono
/// de adorno: toda la tesela responde al tocarla.
///
/// Mide lo mismo en todos los casos, para que la tesela no cambie de alto.
class PieDeTesela extends StatelessWidget {
  const PieDeTesela({
    super.key,
    required this.estado,
    required this.cantidad,
    required this.colores,
    required this.dejarHuecoParaElMenos,
  });

  final EstadoDeTesela estado;

  /// Cuántas piezas de este producto lleva el pedido.
  final int cantidad;

  /// Los colores de la categoría del producto.
  final ParDeColores colores;

  /// Con `true` deja libre la izquierda, donde la tesela dibuja el "−".
  final bool dejarHuecoParaElMenos;

  /// Alto del renglón. Es el mismo que la zona de toque del "−".
  static const alto = 44.0;

  static const _huecoDelMenos = 38.0;

  String get _texto {
    if (estado == EstadoDeTesela.noHay) return 'Hoy no hay';
    if (cantidad > 0) return '$cantidad en cuenta';
    if (estado == EstadoDeTesela.paraElegirTamano) return 'Elegir tamaño';
    return 'Toca para agregar';
  }

  @override
  Widget build(BuildContext context) {
    final estaEnElPedido = cantidad > 0;

    return Container(
      height: alto,
      padding: EdgeInsets.only(
        left: dejarHuecoParaElMenos ? _huecoDelMenos : 0,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            // La raya solo se ve con piezas, pero siempre ocupa su lugar.
            color: estaEnElPedido ? Colores.borde : const Color(0x00000000),
          ),
        ),
      ),
      child: Row(
        spacing: 6,
        children: [
          Expanded(
            // FittedBox encoge el texto si la tesela es muy angosta.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _texto,
                maxLines: 1,
                style: estaEnElPedido
                    ? Tipografia.texto(13, peso: 800)
                    : Tipografia.texto(13, color: Colores.tintaSuave),
              ),
            ),
          ),
          if (estado != EstadoDeTesela.noHay)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: estaEnElPedido
                    ? colores.fondo
                    : Colores.superficieHundida,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                estado == EstadoDeTesela.paraElegirTamano
                    ? Icons.chevron_right_rounded
                    : Icons.add_rounded,
                size: 20,
                color: estaEnElPedido ? colores.tinta : Colores.tintaSuave,
              ),
            ),
        ],
      ),
    );
  }
}
