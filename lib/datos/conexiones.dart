import 'package:http/http.dart' as http;
import 'package:mi_puesto/datos/http/almacen_de_sesion.dart';
import 'package:mi_puesto/datos/http/almacen_de_sesion_seguro.dart';
import 'package:mi_puesto/datos/http/cliente_de_api.dart';
import 'package:mi_puesto/datos/http/repositorio_de_caja_http.dart';
import 'package:mi_puesto/datos/http/repositorio_de_catalogo_http.dart';
import 'package:mi_puesto/datos/http/repositorio_de_categorias_http.dart';
import 'package:mi_puesto/datos/http/repositorio_de_gastos_http.dart';
import 'package:mi_puesto/datos/http/repositorio_de_perfiles_http.dart';
import 'package:mi_puesto/datos/http/repositorio_de_resumen_http.dart';
import 'package:mi_puesto/datos/http/repositorio_de_sesion_http.dart';
import 'package:mi_puesto/datos/http/repositorio_de_ventas_http.dart';
import 'package:mi_puesto/datos/repositorios/repositorios.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_caja_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_catalogo_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_categorias_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_gastos_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_perfiles_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_resumen_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_sesion_simulado.dart';
import 'package:mi_puesto/datos/simulados/repositorio_de_ventas_simulado.dart';
import 'package:mi_puesto/datos/simulados/servidor_simulado.dart';

/// Todas las conexiones con el backend, juntas.
///
/// ESTE ES EL ÚNICO LUGAR que decide de dónde salen los datos: del servidor
/// ([Conexiones.http]) o de la memoria ([Conexiones.simuladas]). Cuál se
/// usa se elige en `main.dart`.
class Conexiones {
  const Conexiones({
    required this.sesion,
    required this.perfiles,
    required this.catalogo,
    required this.categoriasDeProductos,
    required this.categoriasDeGastos,
    required this.ventas,
    required this.caja,
    required this.gastos,
    required this.resumen,
  });

  /// Conexiones de verdad: todo se pide a la API v2 del servidor que está
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
      perfiles: RepositorioDePerfilesHttp(api),
      catalogo: RepositorioDeCatalogoHttp(api),
      categoriasDeProductos: RepositorioDeCategoriasHttp.deProductos(api),
      categoriasDeGastos: RepositorioDeCategoriasHttp.deGastos(api),
      ventas: RepositorioDeVentasHttp(api),
      caja: RepositorioDeCajaHttp(api),
      gastos: RepositorioDeGastosHttp(api),
      resumen: RepositorioDeResumenHttp(api),
    );
  }

  /// Conexiones de mentira: todo vive en memoria y se pierde al cerrar.
  ///
  /// Con [conSesionIniciada] se salta el inicio de sesión y la aplicación
  /// abre directo en "¿Quién vende hoy?" (útil en las pruebas). Con
  /// [conCajaAbierta] en `false` la caja empieza cerrada.
  factory Conexiones.simuladas({
    bool conSesionIniciada = false,
    bool conCajaAbierta = true,
  }) {
    final servidor = ServidorSimulado(
      conSesionIniciada: conSesionIniciada,
      conCajaAbierta: conCajaAbierta,
    );

    return Conexiones(
      sesion: RepositorioDeSesionSimulado(servidor),
      perfiles: RepositorioDePerfilesSimulado(servidor),
      catalogo: RepositorioDeCatalogoSimulado(servidor),
      categoriasDeProductos: RepositorioDeCategoriasSimulado.deProductos(
        servidor,
      ),
      categoriasDeGastos: RepositorioDeCategoriasSimulado.deGastos(servidor),
      ventas: RepositorioDeVentasSimulado(servidor),
      caja: RepositorioDeCajaSimulado(servidor),
      gastos: RepositorioDeGastosSimulado(servidor),
      resumen: RepositorioDeResumenSimulado(servidor),
    );
  }

  final RepositorioDeSesion sesion;
  final RepositorioDePerfiles perfiles;
  final RepositorioDeCatalogo catalogo;
  final RepositorioDeCategorias categoriasDeProductos;
  final RepositorioDeCategorias categoriasDeGastos;
  final RepositorioDeVentas ventas;
  final RepositorioDeCaja caja;
  final RepositorioDeGastos gastos;
  final RepositorioDeResumen resumen;
}
