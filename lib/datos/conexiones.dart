import 'package:http/http.dart' as http;
import 'package:mi_puesto/datos/http/almacen_de_sesion.dart';
import 'package:mi_puesto/datos/http/almacen_de_sesion_seguro.dart';
import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/repositorio_de_caja_http.dart';
import 'package:mi_puesto/datos/http/repositorio_de_catalogo_http.dart';
import 'package:mi_puesto/datos/http/repositorio_de_reportes_http.dart';
import 'package:mi_puesto/datos/http/repositorio_de_sesion_http.dart';
import 'package:mi_puesto/datos/http/repositorio_de_vendedores_http.dart';
import 'package:mi_puesto/datos/http/repositorio_de_ventas_http.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_caja_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_catalogo_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_reportes_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_sesion_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_vendedores_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_ventas_simulado.dart';

/// Todas las conexiones con el backend, juntas.
///
/// ESTE ES EL ÚNICO LUGAR que decide de dónde salen los datos: del servidor
/// ([Conexiones.http]) o de la memoria ([Conexiones.simuladas]). Cuál se
/// usa se elige en `main.dart`.
class Conexiones {
  const Conexiones({
    required this.sesion,
    required this.vendedores,
    required this.catalogo,
    required this.ventas,
    required this.reportes,
    required this.caja,
  });

  /// Conexiones de verdad: todo se pide a la API v1 del servidor que está
  /// en [urlDelServidor] (por ejemplo `https://mi-puesto-back.lunita.me`).
  ///
  /// [almacen] y [cliente] solo se indican en las pruebas, para no tocar
  /// el almacenamiento del dispositivo ni la red.
  factory Conexiones.http({
    required String urlDelServidor,
    AlmacenDeSesion? almacen,
    http.Client? cliente,
  }) {
    final api = ClienteDeApi(
      urlDelServidor: urlDelServidor,
      almacen: almacen ?? AlmacenDeSesionSeguro(),
      cliente: cliente,
    );

    return Conexiones(
      sesion: RepositorioDeSesionHttp(api),
      vendedores: RepositorioDeVendedoresHttp(api),
      catalogo: RepositorioDeCatalogoHttp(api),
      ventas: RepositorioDeVentasHttp(api),
      reportes: RepositorioDeReportesHttp(api),
      caja: RepositorioDeCajaHttp(api),
    );
  }

  /// Conexiones de mentira: todo vive en memoria y se pierde al cerrar.
  ///
  /// Con [conSesionIniciada] se salta el inicio de sesión y la aplicación
  /// abre directo en el PIN (útil en las pruebas).
  Conexiones.simuladas({bool conSesionIniciada = false})
    : sesion = RepositorioDeSesionSimulado(
        conSesionIniciada: conSesionIniciada,
      ),
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
