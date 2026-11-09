import 'package:flutter/widgets.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/pantallas/productos/widgets/columnas_de_tabla.dart';

/// El renglón con los títulos de las columnas de la tabla de productos.
class EncabezadoDeTabla extends StatelessWidget {
  const EncabezadoDeTabla({super.key, required this.esCompacta});

  /// La tabla compacta (teléfono) no tiene Categoría ni Ganas.
  final bool esCompacta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colores.borde, width: 2)),
      ),
      child: Row(
        spacing: 12,
        children: [
          _titulo('Producto', ColumnasDeTabla.producto),
          if (!esCompacta) _titulo('Categoría', ColumnasDeTabla.categoria),
          _titulo('Precio', ColumnasDeTabla.precio, aLaDerecha: true),
          if (!esCompacta)
            _titulo('Ganas', ColumnasDeTabla.ganancia, aLaDerecha: true),
          _titulo('A la venta', ColumnasDeTabla.aLaVenta, aLaDerecha: true),
        ],
      ),
    );
  }

  Widget _titulo(String texto, int ancho, {bool aLaDerecha = false}) {
    return Expanded(
      flex: ancho,
      child: Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: aLaDerecha ? TextAlign.right : TextAlign.left,
        style: Tipografia.texto(14, peso: 800, color: Colores.tintaSuave),
      ),
    );
  }
}
