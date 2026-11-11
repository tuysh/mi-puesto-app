import 'package:flutter/material.dart';

/// Las secciones a las que se llega desde el menú principal.
enum Destino {
  vender('Vender', Icons.shopping_cart_outlined),
  hoy('Hoy', Icons.wb_sunny_outlined),
  reportes('Reportes', Icons.bar_chart_rounded),
  mas('Más', Icons.menu_rounded),
  misVentas('Mis ventas', Icons.receipt_long_outlined);

  const Destino(this.etiqueta, this.icono);

  final String etiqueta;
  final IconData icono;
}

/// Lo que ve la dueña: todo. Lo que no es vender ni consultar vive en "Más".
const destinosDeLaDuena = [
  Destino.vender,
  Destino.hoy,
  Destino.reportes,
  Destino.mas,
];

/// Lo que ve quien solo vende: dos pestañas, y nada más que sus ventas.
const destinosDeQuienVende = [Destino.vender, Destino.misVentas];
