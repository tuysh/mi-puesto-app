/// Datos inventados para poder usar la aplicación sin backend.
/// Son los mismos que aparecen en el diseño.
library;

import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/modelos/puesto.dart';
import 'package:mi_puesto/datos/modelos/vendedor.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

const puestoDeEjemplo = Puesto(id: 'puesto-1', nombre: 'Puesto Doña Mari');

const pinDeEjemplo = '1234';

const vendedoresDeEjemplo = [
  Vendedor(id: 'vendedor-1', nombre: 'Mari', colores: Pasteles.rosa),
  Vendedor(id: 'vendedor-2', nombre: 'Lupe', colores: Pasteles.verde),
  Vendedor(id: 'vendedor-3', nombre: 'Toño', colores: Pasteles.azul),
];

const postres = Categoria(
  id: 'postres',
  nombre: 'Postres',
  emoji: '🍰',
  colores: Pasteles.rosa,
);
const antojos = Categoria(
  id: 'antojos',
  nombre: 'Antojos',
  emoji: '🌮',
  colores: Pasteles.amarillo,
);
const bebidas = Categoria(
  id: 'bebidas',
  nombre: 'Bebidas',
  emoji: '🥤',
  colores: Pasteles.azul,
);
const dulces = Categoria(
  id: 'dulces',
  nombre: 'Dulces',
  emoji: '🍬',
  colores: Pasteles.lila,
);

const categoriasDeEjemplo = [postres, antojos, bebidas, dulces];

final productosDeEjemplo = [
  _producto(1, 'Pay de limón', 'Pay limón', '🥧', 45, 18, postres),
  _producto(2, 'Pastel de chocolate', 'Pastel choco', '🍰', 55, 22, postres),
  _producto(3, 'Flan napolitano', 'Flan', '🍮', 35, 12, postres),
  _producto(4, 'Gelatina', 'Gelatina', '🍧', 20, 7, postres),
  _producto(5, 'Fresas con crema', 'Fresas crema', '🍓', 50, 20, postres),
  _producto(6, 'Elote en vaso', 'Esquite', '🌽', 35, 12, antojos),
  _producto(7, 'Tostilocos', 'Tostilocos', '🌶️', 45, 18, antojos),
  _producto(8, 'Mango con chile', 'Mango', '🥭', 40, 15, antojos),
  _producto(9, 'Papas', 'Papas', '🍟', 30, 10, antojos),
  _producto(10, 'Agua de horchata', 'Horchata', '🥛', 25, 6, bebidas),
  _producto(11, 'Agua de jamaica', 'Jamaica', '🌺', 25, 6, bebidas),
  _producto(12, 'Refresco', 'Refresco', '🥤', 22, 14, bebidas),
  _producto(13, 'Paleta de hielo', 'Paleta', '🍭', 15, 5, dulces),
  _producto(14, 'Dulces', 'Dulces', '🍬', 10, 4, dulces),
];

/// Atajo para escribir la lista de arriba en un renglón por producto.
Producto _producto(
  int numero,
  String nombre,
  String nombreCorto,
  String emoji,
  int precioEnPesos,
  int costoEnPesos,
  Categoria categoria,
) {
  return Producto(
    id: 'producto-$numero',
    nombre: nombre,
    nombreCorto: nombreCorto,
    emoji: emoji,
    precio: Dinero.pesos(precioEnPesos),
    costo: Dinero.pesos(costoEnPesos),
    categoriaId: categoria.id,
  );
}
