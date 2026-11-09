import 'package:flutter/widgets.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_de_pantalla.dart';
import 'package:mi_puesto/pantallas/vender/widgets/pastilla_de_vendedor.dart';

/// Encabezado de "Vender" en teléfono: el nombre del puesto y el título a
/// la izquierda, y quién está vendiendo a la derecha.
class EncabezadoDeVender extends StatelessWidget {
  const EncabezadoDeVender({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = Dependencias.de(context).sesion;

    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: EncabezadoDePantalla(
            sobretitulo: sesion.nombreDelPuesto,
            titulo: 'Vender',
          ),
        ),
        const PastillaDeVendedor(),
      ],
    );
  }
}
