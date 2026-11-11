import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';

/// El lapso de tiempo que cubre un resumen.
enum Periodo {
  dia('Día'),
  semana('Semana'),
  mes('Mes');

  const Periodo(this.etiqueta);

  final String etiqueta;
}

/// Cómo se ordena "Lo más vendido".
enum OrdenDeProductos {
  cantidad('Piezas'),
  monto('Dinero');

  const OrdenDeProductos(this.etiqueta);

  final String etiqueta;
}

/// Las partes del resumen que se le pueden pedir al servidor. Cada una
/// cuesta consultas, así que cada pantalla pide solo las que pinta.
enum SeccionDeResumen {
  totales('totales'),
  porDia('por_dia'),
  masVendidos('top_productos'),
  gastosPorCategoria('gastos_por_categoria');

  const SeccionDeResumen(this.nombreEnElServidor);

  final String nombreEnElServidor;
}

/// Los números de un [Periodo], para "Hoy", "Reportes" y el PDF.
/// Las secciones que no se pidieron llegan vacías.
class Resumen {
  const Resumen({
    required this.periodo,
    required this.desde,
    required this.hasta,
    required this.totales,
    this.porDia = const [],
    this.masVendidos = const [],
    this.gastosPorCategoria = const [],
  });

  final Periodo periodo;
  final DateTime desde;

  /// El último día incluido.
  final DateTime hasta;

  final Totales totales;
  final List<DiaDeResumen> porDia;
  final List<ProductoVendido> masVendidos;
  final List<GastoPorCategoria> gastosPorCategoria;
}

/// La cuenta del periodo: vendido − gastos = utilidad.
class Totales {
  const Totales({
    required this.vendido,
    required this.numeroDeVentas,
    required this.enEfectivo,
    required this.conTarjeta,
    required this.gastos,
    required this.utilidad,
  });

  static const enCeros = Totales(
    vendido: Dinero.cero,
    numeroDeVentas: 0,
    enEfectivo: Dinero.cero,
    conTarjeta: Dinero.cero,
    gastos: Dinero.cero,
    utilidad: Dinero.cero,
  );

  final Dinero vendido;
  final int numeroDeVentas;
  final Dinero enEfectivo;
  final Dinero conTarjeta;
  final Dinero gastos;

  /// Puede ser negativa.
  final Dinero utilidad;
}

/// Los números de un solo día dentro del periodo.
class DiaDeResumen {
  const DiaDeResumen({
    required this.dia,
    required this.numeroDeVentas,
    required this.vendido,
    required this.gastos,
    required this.utilidad,
  });

  final DateTime dia;
  final int numeroDeVentas;
  final Dinero vendido;
  final Dinero gastos;
  final Dinero utilidad;
}

/// Cuánto se vendió de un producto. Cada tamaño cuenta aparte.
class ProductoVendido {
  const ProductoVendido({
    required this.nombreDelProducto,
    required this.nombreDelTamano,
    required this.categoriaId,
    required this.representacion,
    required this.emoji,
    required this.letras,
    required this.imagenUrl,
    required this.piezas,
    required this.vendido,
  });

  final String nombreDelProducto;

  /// Vacío si el producto no tiene tamaños.
  final String nombreDelTamano;

  final String? categoriaId;
  final Representacion representacion;
  final String emoji;
  final String letras;
  final String imagenUrl;
  final int piezas;
  final Dinero vendido;

  /// El nombre con su tamaño: "Horchata grande".
  String get nombreCompleto {
    return unirNombreYTamano(nombreDelProducto, nombreDelTamano);
  }
}

/// Cuánto se gastó en una categoría.
class GastoPorCategoria {
  const GastoPorCategoria({
    required this.nombre,
    required this.color,
    required this.total,
  });

  /// `null` en el renglón de los gastos sin categoría.
  final String? nombre;

  /// Número del pastel de la categoría; `null` si no tiene.
  final int? color;

  final Dinero total;
}
