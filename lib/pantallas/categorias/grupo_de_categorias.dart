/// Las dos clases de categorías que hay: las de productos y las de gastos.
/// Funcionan igual; solo cambian los textos.
enum GrupoDeCategorias {
  deProductos(
    etiqueta: 'De productos',
    ayuda: 'Sirven para filtrar los productos al vender.',
    ejemplo: 'Ej. Helados',
    unUso: 'producto',
    variosUsos: 'productos',
    queLesPasaAlEliminar: 'Sus productos quedan sin categoría.',
  ),
  deGastos(
    etiqueta: 'De gastos',
    ayuda:
        'Tú las creas; la app no trae ninguna. Sirven para ver en qué se '
        'va el dinero.',
    ejemplo: 'Ej. Luz',
    unUso: 'gasto',
    variosUsos: 'gastos',
    queLesPasaAlEliminar: 'Sus gastos quedan sin categoría.',
  );

  const GrupoDeCategorias({
    required this.etiqueta,
    required this.ayuda,
    required this.ejemplo,
    required this.unUso,
    required this.variosUsos,
    required this.queLesPasaAlEliminar,
  });

  /// El texto de su botón en el selector.
  final String etiqueta;

  /// Para qué sirven estas categorías.
  final String ayuda;

  /// El ejemplo que se ve en el campo de "Nueva categoría".
  final String ejemplo;

  final String unUso;
  final String variosUsos;
  final String queLesPasaAlEliminar;

  /// "5 productos", "1 gasto"…
  String textoDeUsos(int usos) => '$usos ${usos == 1 ? unUso : variosUsos}';
}
