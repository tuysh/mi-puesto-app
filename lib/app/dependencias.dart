import 'package:flutter/widgets.dart';
import 'package:mi_puesto/controladores/controlador_de_catalogo.dart';
import 'package:mi_puesto/controladores/controlador_de_pedido.dart';
import 'package:mi_puesto/controladores/controlador_de_ventas.dart';
import 'package:mi_puesto/controladores/sesion.dart';
import 'package:mi_puesto/datos/conexiones.dart';
import 'package:mi_puesto/nucleo/pedir_foto.dart';

/// Pone al alcance de cualquier pantalla los objetos compartidos de la
/// aplicación. Desde cualquier widget se obtienen así:
///
/// ```dart
/// final pedido = Dependencias.de(context).pedido;
/// ```
///
/// Los controladores avisan cuando cambian; para redibujar un widget al
/// cambiar uno, envuélvelo en un `ListenableBuilder`.
class Dependencias extends InheritedWidget {
  const Dependencias({
    super.key,
    required this.conexiones,
    required this.sesion,
    required this.catalogo,
    required this.pedido,
    required this.ventas,
    required this.pedirFoto,
    required super.child,
  });

  final Conexiones conexiones;
  final Sesion sesion;
  final ControladorDeCatalogo catalogo;
  final ControladorDePedido pedido;
  final ControladorDeVentas ventas;

  /// Abre la cámara o la galería para elegir la foto de un producto.
  final PedirFoto pedirFoto;

  static Dependencias de(BuildContext context) {
    final dependencias = context.getInheritedWidgetOfExactType<Dependencias>();
    assert(dependencias != null, 'Falta Dependencias arriba de este widget.');
    return dependencias!;
  }

  /// Los objetos nunca se reemplazan, así que no hay nada que notificar.
  @override
  bool updateShouldNotify(Dependencias oldWidget) => false;
}
