import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';

/// Cómo pagó el cliente.
enum MetodoDePago {
  efectivo('Efectivo'),
  tarjeta('Tarjeta');

  const MetodoDePago(this.etiqueta);

  final String etiqueta;
}

/// Una venta ya registrada.
class Venta {
  const Venta({
    required this.id,
    required this.creadaEn,
    required this.perfilId,
    required this.metodoDePago,
    required this.total,
    required this.lineas,
    this.montoRecibido,
    this.cambio,
    this.nota = '',
    this.editadaEn,
    this.canceladaEn,
    this.eventos = const [],
    this.sePuedeCambiar = false,
  });

  final String id;
  final DateTime creadaEn;

  /// Quién la registró.
  final String perfilId;

  final MetodoDePago metodoDePago;
  final Dinero total;
  final List<LineaDeVenta> lineas;

  /// Con cuánto pagó el cliente. `null` si pagó con tarjeta.
  final Dinero? montoRecibido;

  /// Lo que se le devolvió. `null` si pagó con tarjeta.
  final Dinero? cambio;

  final String nota;

  /// Cuándo se editó por última vez; `null` si nunca.
  final DateTime? editadaEn;

  /// Cuándo se canceló; `null` si sigue contando.
  final DateTime? canceladaEn;

  /// El historial de ediciones y cancelación. Solo viene al pedir UNA
  /// venta; en las listas llega vacío.
  final List<EventoDeVenta> eventos;

  /// `true` si quien la mira puede editarla o cancelarla: es la dueña, no
  /// está cancelada y la caja de ese día sigue abierta. Lo decide el
  /// servidor y solo viene al pedir UNA venta.
  final bool sePuedeCambiar;

  bool get estaCancelada => canceladaEn != null;
  bool get fueEditada => editadaEn != null;
}

/// Un renglón de una venta, con el nombre y el precio que tenía el producto
/// en el momento de cobrar (después pueden haber cambiado).
class LineaDeVenta {
  const LineaDeVenta({
    required this.productoId,
    required this.presentacionId,
    required this.nombreDelProducto,
    required this.nombreDelTamano,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  final String productoId;

  /// `null` si el producto no tiene tamaños.
  final String? presentacionId;

  final String nombreDelProducto;

  /// Vacío si el producto no tiene tamaños.
  final String nombreDelTamano;

  final int cantidad;
  final Dinero precioUnitario;
  final Dinero subtotal;

  /// El nombre con su tamaño: "Horchata grande".
  String get nombreCompleto {
    return unirNombreYTamano(nombreDelProducto, nombreDelTamano);
  }

  /// Devuelve el mismo renglón con otra cantidad (y su subtotal).
  LineaDeVenta conCantidad(int cantidadNueva) {
    return LineaDeVenta(
      productoId: productoId,
      presentacionId: presentacionId,
      nombreDelProducto: nombreDelProducto,
      nombreDelTamano: nombreDelTamano,
      cantidad: cantidadNueva,
      precioUnitario: precioUnitario,
      subtotal: precioUnitario * cantidadNueva,
    );
  }
}

enum TipoDeEvento { edicion, cancelacion }

/// Algo que le pasó a una venta después de registrarla: quién y cuándo.
class EventoDeVenta {
  const EventoDeVenta({
    required this.tipo,
    required this.perfilId,
    required this.ocurrioEn,
  });

  final TipoDeEvento tipo;
  final String perfilId;
  final DateTime ocurrioEn;
}

/// Las ventas de un día, de la más nueva a la más vieja.
class VentasDelDia {
  const VentasDelDia({
    required this.fecha,
    required this.total,
    required this.cuantas,
    required this.canceladas,
    required this.ventas,
  });

  final DateTime fecha;

  /// Lo vendido, sin contar las canceladas.
  final Dinero total;

  /// Cuántas ventas cuentan (sin las canceladas).
  final int cuantas;

  final int canceladas;

  /// Todas, también las canceladas.
  final List<Venta> ventas;
}

/// Lo que se manda al servidor para registrar o editar una venta.
class LineaPorCobrar {
  const LineaPorCobrar({
    required this.productoId,
    required this.cantidad,
    this.presentacionId,
  });

  final String productoId;
  final String? presentacionId;
  final int cantidad;
}
