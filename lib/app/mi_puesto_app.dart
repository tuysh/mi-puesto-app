import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/controladores/controlador_de_catalogo.dart';
import 'package:mi_puesto/controladores/controlador_de_pedido.dart';
import 'package:mi_puesto/controladores/controlador_de_ventas.dart';
import 'package:mi_puesto/controladores/sesion.dart';
import 'package:mi_puesto/datos/conexiones.dart';
import 'package:mi_puesto/nucleo/tema/tema.dart';
import 'package:mi_puesto/pantallas/acceso/pantalla_de_pin.dart';

/// La raíz de la aplicación: crea los objetos compartidos y abre la
/// pantalla del PIN.
class MiPuestoApp extends StatefulWidget {
  const MiPuestoApp({super.key, this.conexiones});

  /// De dónde salen los datos. Si no se indica, se usan datos simulados.
  final Conexiones? conexiones;

  @override
  State<MiPuestoApp> createState() => _EstadoDeMiPuestoApp();
}

class _EstadoDeMiPuestoApp extends State<MiPuestoApp> {
  late final Conexiones _conexiones;
  late final Sesion _sesion;
  late final ControladorDeCatalogo _catalogo;
  late final ControladorDePedido _pedido;
  late final ControladorDeVentas _ventas;

  @override
  void initState() {
    super.initState();

    _conexiones = widget.conexiones ?? Conexiones.simuladas();
    _sesion = Sesion(_conexiones.sesion);
    _catalogo = ControladorDeCatalogo(_conexiones.catalogo);
    _pedido = ControladorDePedido();
    _ventas = ControladorDeVentas(
      repositorio: _conexiones.ventas,
      pedido: _pedido,
      sesion: _sesion,
    );

    _sesion.cargarPuesto();
  }

  @override
  void dispose() {
    _ventas.dispose();
    _pedido.dispose();
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
      pedido: _pedido,
      ventas: _ventas,
      child: MaterialApp(
        title: 'Mi puesto',
        debugShowCheckedModeBanner: false,
        theme: crearTema(),
        home: const PantallaDePin(),
      ),
    );
  }
}
