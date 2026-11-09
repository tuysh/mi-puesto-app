import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_caja_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_catalogo_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_reportes_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_sesion_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_vendedores_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_ventas_simulado.dart';

/// Todas las conexiones con el backend, juntas.
///
/// ESTE ES EL ÚNICO LUGAR que decide de dónde salen los datos. Cuando exista
/// el backend, agrega aquí otro constructor (por ejemplo `Conexiones.http`)
/// que use los repositorios reales y cámbialo en `app/mi_puesto_app.dart`.
class Conexiones {
  const Conexiones({
    required this.sesion,
    required this.vendedores,
    required this.catalogo,
    required this.ventas,
    required this.reportes,
    required this.caja,
  });

  /// Conexiones de mentira: todo vive en memoria y se pierde al cerrar.
  Conexiones.simuladas()
    : sesion = RepositorioDeSesionSimulado(),
      vendedores = RepositorioDeVendedoresSimulado(),
      catalogo = RepositorioDeCatalogoSimulado(),
      ventas = RepositorioDeVentasSimulado(),
      reportes = RepositorioDeReportesSimulado(),
      caja = RepositorioDeCajaSimulado();

  final RepositorioDeSesion sesion;
  final RepositorioDeVendedores vendedores;
  final RepositorioDeCatalogo catalogo;
  final RepositorioDeVentas ventas;
  final RepositorioDeReportes reportes;
  final RepositorioDeCaja caja;
}
