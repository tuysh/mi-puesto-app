import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';

/// Todo lo que pinta "Vender": las categorías y los productos activos, ya
/// en el orden en que se muestran.
class Catalogo {
  const Catalogo({required this.categorias, required this.productos});

  final List<Categoria> categorias;
  final List<Producto> productos;
}
