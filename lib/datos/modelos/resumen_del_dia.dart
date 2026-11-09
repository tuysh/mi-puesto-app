import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';

/// Los números del día que se muestran en la pantalla "Hoy".
class ResumenDelDia {
  const ResumenDelDia({
    required this.fecha,
    required this.vendido,
    required this.ganancia,
    required this.numeroDeVentas,
    required this.masVendidos,
    required this.ventasPorVendedor,
  });

  final DateTime fecha;
  final Dinero vendido;
  final Dinero ganancia;
  final int numeroDeVentas;

  /// Ordenados del más vendido al menos vendido.
  final List<ProductoVendido> masVendidos;

  final List<VentaPorVendedor> ventasPorVendedor;
}

/// Cuántas piezas se vendieron de un producto.
class ProductoVendido {
  const ProductoVendido({required this.producto, required this.piezas});

  final Producto producto;
  final int piezas;
}

/// Cuánto dinero vendió una persona.
class VentaPorVendedor {
  const VentaPorVendedor({required this.nombre, required this.total});

  final String nombre;
  final Dinero total;
}
