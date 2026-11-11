import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/controladores/controlador_de_caja.dart';
import 'package:mi_puesto/controladores/controlador_de_catalogo.dart';
import 'package:mi_puesto/controladores/controlador_de_pedido.dart';
import 'package:mi_puesto/controladores/controlador_de_ventas.dart';
import 'package:mi_puesto/controladores/sesion.dart';
import 'package:mi_puesto/datos/conexiones.dart';
import 'package:mi_puesto/nucleo/pedir_foto.dart';
import 'package:mi_puesto/nucleo/tema/tema.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_de_arranque.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_de_iniciar_sesion.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_quien_vende.dart';

/// La raíz de la aplicación: crea los objetos compartidos y abre la
/// pantalla de arranque, que decide por dónde se entra.
class MiPuestoApp extends StatefulWidget {
  const MiPuestoApp({
    super.key,
    this.conexiones,
    this.pedirFoto = pedirFotoDelDispositivo,
  });

  /// De dónde salen los datos. Si no se indica, se usan datos simulados.
  final Conexiones? conexiones;

  /// Cómo se le pide una foto a la persona. Solo se cambia en las pruebas,
  /// donde no hay cámara ni galería.
  final PedirFoto pedirFoto;

  @override
  State<MiPuestoApp> createState() => _EstadoDeMiPuestoApp();
}

class _EstadoDeMiPuestoApp extends State<MiPuestoApp> {
  late final Conexiones _conexiones;
  late final Sesion _sesion;
  late final ControladorDeCatalogo _catalogo;
  late final ControladorDeCaja _caja;
  late final ControladorDePedido _pedido;
  late final ControladorDeVentas _ventas;

  /// Permite cambiar de pantalla desde aquí, fuera de cualquier pantalla.
  final _navegador = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    _conexiones = widget.conexiones ?? Conexiones.simuladas();
    _sesion = Sesion(_conexiones.sesion);
    _catalogo = ControladorDeCatalogo(_conexiones.catalogo);
    _caja = ControladorDeCaja(_conexiones.caja);
    _pedido = ControladorDePedido();
    _ventas = ControladorDeVentas(
      repositorio: _conexiones.ventas,
      pedido: _pedido,
    );

    _sesion.alPerderLaSesion = () {
      _dejarSoloLaPantalla(const PantallaDeIniciarSesion());
    };
    _sesion.alQuedarSinNadieDentro = () {
      _dejarSoloLaPantalla(const PantallaQuienVende());
    };
  }

  /// El servidor dejó de reconocer la sesión (o a quien estaba dentro): se
  /// suelta lo que estaba a medias y se vuelve a pedir la entrada.
  void _dejarSoloLaPantalla(Widget pantalla) {
    _pedido.vaciar();
    _ventas.cerrarAviso();
    _navegador.currentState?.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (context) => pantalla),
      (ruta) => false,
    );
  }

  @override
  void dispose() {
    _ventas.dispose();
    _pedido.dispose();
    _caja.dispose();
    _catalogo.dispose();
    _sesion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dependencias(
      conexiones: _conexiones,
      sesion: _sesion,
      catalogo: _catalogo,
      caja: _caja,
      pedido: _pedido,
      ventas: _ventas,
      pedirFoto: widget.pedirFoto,
      child: MaterialApp(
        title: 'Mi puesto',
        navigatorKey: _navegador,
        debugShowCheckedModeBanner: false,
        theme: crearTema(),
        // En español, para que el calendario (al elegir fechas) no salga
        // en inglés.
        locale: const Locale('es', 'MX'),
        supportedLocales: const [Locale('es', 'MX')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const PantallaDeArranque(),
      ),
    );
  }
}
