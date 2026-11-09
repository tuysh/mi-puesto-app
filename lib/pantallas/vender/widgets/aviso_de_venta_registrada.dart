import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/cifra.dart';

/// El aviso verde que confirma una venta: cuánto pagó el cliente y, en
/// grande, el cambio que hay que darle. Incluye el botón para corregir.
class AvisoDeVentaRegistrada extends StatelessWidget {
  const AvisoDeVentaRegistrada({
    super.key,
    required this.venta,
    required this.alCerrar,
    required this.alCorregir,
  });

  final Venta venta;
  final VoidCallback alCerrar;
  final VoidCallback alCorregir;

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
          BotonDeContorno(
            texto: 'Me equivoqué: corregir pedido',
            alTocar: alCorregir,
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
    final pago = formatearDinero(venta.pagoCon);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          'Venta registrada · pagó $pago',
          style: Tipografia.texto(15, peso: 800, color: _verde.tinta),
        ),
        // FittedBox encoge el renglón si el cambio es tan grande que no cabe.
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
                'Cambio',
                style: Tipografia.texto(17, peso: 800, color: _verde.tinta),
              ),
              Cifra(
                formatearDinero(venta.cambio),
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
