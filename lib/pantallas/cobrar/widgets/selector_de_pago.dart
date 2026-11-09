import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/pantallas/cobrar/billetes.dart';
import 'package:mi_puesto/pantallas/cobrar/pedir_otro_monto.dart';
import 'package:mi_puesto/pantallas/cobrar/widgets/boton_de_billete.dart';

/// La fila de botones para indicar con cuánto pagó el cliente: los billetes
/// comunes y "Otro…" para escribir cualquier monto.
class SelectorDePago extends StatelessWidget {
  const SelectorDePago({
    super.key,
    required this.total,
    required this.pagoCon,
    required this.alCambiar,
    this.altoDeBoton = 56,
  });

  /// El total a cobrar. Los billetes menores a esto se apagan.
  final Dinero total;

  /// El monto elegido; `null` si no se ha elegido ninguno (pago exacto).
  final Dinero? pagoCon;

  /// Recibe el monto elegido, o `null` cuando se quita la selección.
  final ValueChanged<Dinero?> alCambiar;

  final double altoDeBoton;

  /// `true` si el monto elegido se escribió a mano con "Otro…".
  bool get _eligioOtroMonto {
    return pagoCon != null && !billetesComunes.contains(pagoCon);
  }

  void _tocarBillete(Dinero billete) {
    // Tocar el billete que ya estaba elegido lo deselecciona.
    final yaEstabaElegido = pagoCon == billete;
    alCambiar(yaEstabaElegido ? null : billete);
  }

  Future<void> _tocarOtro(BuildContext context) async {
    final monto = await pedirOtroMonto(context, total: total);
    if (monto != null) alCambiar(monto);
  }

  @override
  Widget build(BuildContext context) {
    final pagoCon = this.pagoCon;

    return Row(
      spacing: 8,
      children: [
        for (final billete in billetesComunes)
          Expanded(
            child: BotonDeBillete(
              texto: formatearDinero(billete),
              estaElegido: pagoCon == billete,
              alTocar: billete < total ? null : () => _tocarBillete(billete),
              alto: altoDeBoton,
            ),
          ),
        Expanded(
          child: BotonDeBillete(
            texto: (pagoCon != null && _eligioOtroMonto)
                ? formatearDinero(pagoCon)
                : 'Otro…',
            estaElegido: _eligioOtroMonto,
            alTocar: () => _tocarOtro(context),
            alto: altoDeBoton,
          ),
        ),
      ],
    );
  }
}
