import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';
import 'package:mi_puesto/nucleo/widgets/logo_del_puesto.dart';
import 'package:mi_puesto/pantallas/principal/widgets/pastilla_de_persona.dart';

/// Encabezado de "Vender" en teléfono: el logo, el nombre del puesto y el
/// título a la izquierda, y quién está dentro a la derecha.
class EncabezadoDeVender extends StatelessWidget {
  const EncabezadoDeVender({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = Dependencias.de(context).sesion;

    return Row(
      spacing: 12,
      children: [
        const LogoDelPuesto(tamano: 44, altoDeSombra: 3),
        Expanded(
          child: EncabezadoDePantalla(
            sobretitulo: sesion.nombreDelNegocio,
            titulo: 'Vender',
          ),
        ),
        const PastillaDePersona(),
      ],
    );
  }
}
