import 'package:mi_puesto/datos/modelos/dinero.dart';

/// La cuenta de cuánto dinero debería haber en la caja al final del día.
class CuentaDeCaja {
  const CuentaDeCaja({
    required this.fecha,
    required this.fondoInicial,
    required this.vendidoEnEfectivo,
  });

  final DateTime fecha;

  /// El dinero con el que se abrió la caja.
  final Dinero fondoInicial;

  final Dinero vendidoEnEfectivo;

  Dinero get debeHaber => fondoInicial + vendidoEnEfectivo;
}

/// Lo que la persona captura al cerrar la caja.
class CierreDeCaja {
  const CierreDeCaja({required this.contado, required this.nota});

  /// El dinero que realmente se contó en la caja.
  final Dinero contado;

  /// Comentario opcional; vacío si no se escribió nada.
  final String nota;
}
