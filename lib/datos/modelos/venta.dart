import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/vendedor.dart';

/// Una venta ya registrada.
class Venta {
  const Venta({
    required this.id,
    required this.lineas,
    required this.total,
    required this.pagoCon,
    required this.vendedor,
    required this.fecha,
  });

  final String id;
  final List<LineaDePedido> lineas;
  final Dinero total;

  /// El dinero que entregó el cliente (igual o mayor que [total]).
  final Dinero pagoCon;

  final Vendedor vendedor;
  final DateTime fecha;

  /// Lo que hay que devolverle al cliente.
  Dinero get cambio => pagoCon - total;
}
