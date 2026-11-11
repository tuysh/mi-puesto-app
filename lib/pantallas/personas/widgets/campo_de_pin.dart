import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/tarjeta_de_contorno.dart';

/// El recuadro del PIN al editar a una persona. El PIN nunca se muestra:
/// se ven cuatro puntos (o un aviso de que falta) y un enlace para poner
/// uno nuevo.
class CampoDePin extends StatelessWidget {
  const CampoDePin({
    super.key,
    required this.tienePin,
    required this.hayPinNuevo,
    required this.alCambiar,
  });

  /// `false` solo al agregar a una persona, antes de ponerle su PIN.
  final bool tienePin;

  /// `true` si ya se escribió un PIN nuevo que todavía no se guarda.
  final bool hayPinNuevo;

  final VoidCallback alCambiar;

  @override
  Widget build(BuildContext context) {
    return TarjetaDeContorno(
      relleno: const EdgeInsets.fromLTRB(18, 7, 8, 7),
      child: Row(
        spacing: 14,
        children: [
          Expanded(
            child: tienePin
                ? Semantics(
                    label: hayPinNuevo
                        ? 'PIN nuevo sin guardar'
                        : 'PIN guardado',
                    child: Row(
                      spacing: 12,
                      children: [
                        for (var punto = 0; punto < 4; punto++) const _Punto(),
                        if (hayPinNuevo)
                          Text(
                            'nuevo',
                            style: Tipografia.texto(
                              14,
                              color: Colores.tintaSuave,
                            ),
                          ),
                      ],
                    ),
                  )
                : Text(
                    'Todavía no tiene',
                    style: Tipografia.texto(
                      16,
                      peso: 600,
                      color: Colores.tintaSuave,
                    ),
                  ),
          ),
          BotonDeEnlace(
            texto: tienePin ? 'Cambiar PIN' : 'Poner PIN',
            alTocar: alCambiar,
          ),
        ],
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  const _Punto();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        color: Colores.tinta,
        shape: BoxShape.circle,
      ),
    );
  }
}
