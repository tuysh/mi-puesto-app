import 'package:flutter/material.dart';

/// Las secciones a las que se llega desde el menú principal.
enum Destino {
  vender('Vender', Icons.shopping_cart_outlined),
  hoy('Hoy', Icons.wb_sunny_outlined),
  reportes('Reportes', Icons.bar_chart_rounded),
  historial('Historial', Icons.receipt_long_outlined),
  productos('Productos', Icons.inventory_2_outlined),
  mas('Más', Icons.menu_rounded);

  const Destino(this.etiqueta, this.icono);

  final String etiqueta;
  final IconData icono;
}

/// En teléfono solo caben cuatro botones; Historial y Productos viven
/// dentro de "Más".
const destinosDeTelefono = [
  Destino.vender,
  Destino.hoy,
  Destino.reportes,
  Destino.mas,
];

/// En tablet el menú lateral muestra todas las secciones directamente.
const destinosDeTablet = [
  Destino.vender,
  Destino.hoy,
  Destino.reportes,
  Destino.historial,
  Destino.productos,
];
