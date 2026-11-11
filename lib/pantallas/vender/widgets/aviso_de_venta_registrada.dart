import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';

/// El aviso verde que confirma una venta: cómo pagó el cliente y, en
/// grande, el cambio que hay que darle (o el total, si pagó con tarjeta).
class AvisoDeVentaRegistrada extends StatelessWidget {
  const AvisoDeVentaRegistrada({
    super.key,
    required this.venta,
    required this.alCerrar,
    required this.alVerOCorregir,
  });

  final Venta venta;
  final VoidCallback alCerrar;

  /// Abre el detalle de la venta. Si es `null` no se dibuja el botón:
  /// quien solo vende no puede corregir.
  final VoidCallback? alVerOCorregir;

  static const _verde = Colores.exito;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: _verde.fondo,
        borderRadius: BorderRadius.circular(Radios.tarjetaGrande),
        boxShadow: Sombras.flotante,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            spacing: 12,
            children: [
              const _Palomita(),
              Expanded(child: _construirTextos()),
              IconButton(
                tooltip: 'Cerrar aviso',
                onPressed: alCerrar,
                icon: const Icon(Icons.close_rounded, size: 26),
                color: _verde.tinta,
              ),
            ],
          ),
          if (alVerOCorregir != null)
            BotonDeContorno(
              texto: 'Ver o corregir esta venta',
              alTocar: alVerOCorregir,
              alto: 44,
              tamanoDeTexto: 15,
              color: _verde.tinta,
              fondo: const Color(0x99FFFFFF),
            ),
        ],
      ),
    );
  }

  Widget _construirTextos() {
    final cambio = venta.cambio;
    final montoRecibido = venta.montoRecibido;
    final fueConTarjeta = cambio == null || montoRecibido == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          fueConTarjeta
              ? 'Venta registrada · tarjeta'
              : 'Venta registrada · efectivo, pagó '
                    '${formatearDinero(montoRecibido)}',
          style: Tipografia.texto(15, peso: 800, color: _verde.tinta),
        ),
        // FittedBox encoge el renglón si el monto es tan grande que no cabe.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 8,
            children: [
              Text(
                // Con tarjeta no hay cambio: se muestra lo cobrado.
                fueConTarjeta ? 'Cobrado' : 'Cambio',
                style: Tipografia.texto(17, peso: 800, color: _verde.tinta),
              ),
              Cifra(
                formatearDinero(fueConTarjeta ? venta.total : cambio),
                tamano: 40,
                peso: 750,
                color: _verde.tinta,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Círculo verde con una palomita blanca.
class _Palomita extends StatelessWidget {
  const _Palomita();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colores.exito.tinta,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_rounded,
        color: Colores.superficie,
        size: 28,
      ),
    );
  }
}
