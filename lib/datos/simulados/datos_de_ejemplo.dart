/// Datos inventados para poder usar la aplicación sin backend.
/// Son los mismos que aparecen en el diseño y en el negocio de ejemplo del
/// servidor.
library;

import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/negocio.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/datos/modelos/presentacion.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';

/// La cuenta que ya existe al abrir la aplicación con datos simulados.
const correoDeEjemplo = 'mari@ejemplo.com';
const contrasenaDeEjemplo = 'pay-de-limon';

const negocioDeEjemplo = Negocio(
  id: '1',
  nombre: 'Puesto Doña Mari',
  correo: correoDeEjemplo,
);

const mari = Perfil(id: '1', nombre: 'Mari', rol: Rol.dueno, color: 0);
const lupe = Perfil(id: '2', nombre: 'Lupe', rol: Rol.vendedor, color: 1);
const tono = Perfil(id: '3', nombre: 'Toño', rol: Rol.vendedor, color: 2);

const perfilesDeEjemplo = [mari, lupe, tono];

/// El PIN de cada persona de ejemplo, por su `id`.
const pinesDeEjemplo = {'1': '1234', '2': '1111', '3': '2222'};

const postres = Categoria(id: '1', nombre: 'Postres', color: 0);
const antojos = Categoria(id: '2', nombre: 'Antojos', color: 3);
const bebidas = Categoria(id: '3', nombre: 'Bebidas', color: 2);
const dulces = Categoria(id: '4', nombre: 'Dulces', color: 4);

const categoriasDeEjemplo = [postres, antojos, bebidas, dulces];

const categoriasDeGastosDeEjemplo = [
  Categoria(id: '1', nombre: 'Ingredientes', color: 0),
  Categoria(id: '2', nombre: 'Desechables', color: 1),
  Categoria(id: '3', nombre: 'Gas', color: 2),
  Categoria(id: '4', nombre: 'Plaza', color: 3),
  Categoria(id: '5', nombre: 'Transporte', color: 4),
];

/// Los dos tamaños de las aguas.
const _chicaYGrande = [15, 25];

final productosDeEjemplo = [
  _producto(1, 'Pay limón', '🥧', 45, postres),
  _producto(2, 'Pastel choco', '🍰', 55, postres),
  _producto(3, 'Flan', '🍮', 35, postres),
  _producto(4, 'Gelatina', '🍧', 20, postres),
  _producto(5, 'Fresas crema', '🍓', 50, postres),
  _producto(6, 'Esquite', '🌽', 35, antojos),
  _producto(7, 'Tostilocos', '', 45, antojos, letras: 'To'),
  // Mango está marcado "hoy no hay": se ve, pero no se puede agregar.
  _producto(8, 'Mango', '🥭', 40, antojos, disponible: false),
  _producto(9, 'Papas', '🍟', 30, antojos),
  _producto(10, 'Horchata', '🥛', 0, bebidas, tamanos: _chicaYGrande),
  _producto(11, 'Jamaica', '🌺', 0, bebidas, tamanos: _chicaYGrande),
  _producto(12, 'Refresco', '🥤', 22, bebidas),
  _producto(13, 'Paleta', '🍭', 15, dulces),
  _producto(14, 'Dulces', '🍬', 10, dulces),
];

/// Atajo para escribir la lista de arriba en un renglón por producto.
/// Con [tamanos] (los precios de "Chica" y "Grande") el producto no tiene
/// precio propio.
Producto _producto(
  int numero,
  String nombre,
  String emoji,
  int precioEnPesos,
  Categoria categoria, {
  String letras = '',
  bool disponible = true,
  List<int> tamanos = const [],
}) {
  return Producto(
    id: '$numero',
    nombre: nombre,
    categoriaId: categoria.id,
    precio: tamanos.isEmpty ? Dinero.pesos(precioEnPesos) : null,
    presentaciones: [
      if (tamanos.isNotEmpty) ...[
        Presentacion(
          id: '${numero}1',
          nombre: 'Chica',
          precio: Dinero.pesos(tamanos[0]),
        ),
        Presentacion(
          id: '${numero}2',
          nombre: 'Grande',
          precio: Dinero.pesos(tamanos[1]),
        ),
      ],
    ],
    representacion: emoji.isEmpty
        ? Representacion.letras
        : Representacion.emoji,
    emoji: emoji,
    letras: letras,
    disponible: disponible,
  );
}
