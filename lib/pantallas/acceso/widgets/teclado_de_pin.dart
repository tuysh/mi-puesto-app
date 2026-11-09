import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/tecla_de_pin.dart';

/// El teclado numérico para escribir el PIN: del 1 al 9, el 0 y borrar.
class TecladoDePin extends StatelessWidget {
  const TecladoDePin({
    super.key,
    required this.alTocarDigito,
    required this.alBorrar,
  });

  /// Recibe el dígito tocado, como texto: "0" a "9".
  final ValueChanged<String> alTocarDigito;

  final VoidCallback alBorrar;

  static const _espacioHorizontal = 22.0;
  static const _espacioVertical = 16.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: _espacioVertical,
      children: [
        _fila([_teclaDeDigito('1'), _teclaDeDigito('2'), _teclaDeDigito('3')]),
        _fila([_teclaDeDigito('4'), _teclaDeDigito('5'), _teclaDeDigito('6')]),
        _fila([_teclaDeDigito('7'), _teclaDeDigito('8'), _teclaDeDigito('9')]),
        _fila([_hueco(), _teclaDeDigito('0'), _teclaDeBorrar()]),
      ],
    );
  }

  Widget _fila(List<Widget> teclas) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: _espacioHorizontal,
      children: teclas,
    );
  }

  Widget _teclaDeDigito(String digito) {
    return TeclaDePin(
      etiqueta: digito,
      alTocar: () => alTocarDigito(digito),
      child: Text(digito, style: Tipografia.titulo(30, peso: 650)),
    );
  }

  Widget _teclaDeBorrar() {
    return TeclaDePin(
      etiqueta: 'Borrar',
      esSecundaria: true,
      alTocar: alBorrar,
      child: const Icon(
        Icons.arrow_back_rounded,
        color: Colores.tinta,
        size: 30,
      ),
    );
  }

  /// Espacio vacío del tamaño de una tecla, a la izquierda del 0.
  Widget _hueco() {
    return const SizedBox(width: TeclaDePin.tamano, height: TeclaDePin.tamano);
  }
}
