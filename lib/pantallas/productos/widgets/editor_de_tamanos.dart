import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_texto.dart';
import 'package:mi_puesto/pantallas/productos/tamano_en_edicion.dart';

/// En el formulario de un producto con varios tamaños: un renglón por
/// tamaño (su nombre, su precio y una "✕" para quitarlo) y el enlace para
/// agregar otro.
class EditorDeTamanos extends StatelessWidget {
  const EditorDeTamanos({
    super.key,
    required this.tamanos,
    required this.alAgregar,
    required this.alQuitar,
  });

  final List<TamanoEnEdicion> tamanos;
  final VoidCallback alAgregar;

  /// Recibe el renglón que se quiere quitar.
  final ValueChanged<TamanoEnEdicion> alQuitar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        for (final (posicion, tamano) in tamanos.indexed)
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Semantics(
                  label: 'Nombre del tamaño ${posicion + 1}',
                  child: CampoDeTexto(
                    controlador: tamano.nombre,
                    sugerencia: 'Ej. Chica',
                  ),
                ),
              ),
              SizedBox(
                width: 104,
                child: Semantics(
                  label: 'Precio del tamaño ${posicion + 1}',
                  child: CampoDeTexto(
                    controlador: tamano.precio,
                    prefijo: '\$',
                    esNumero: true,
                    estilo: Tipografia.cifra(19),
                  ),
                ),
              ),
              _BotonDeQuitarTamano(
                etiqueta: 'Quitar tamaño ${tamano.nombre.text}'.trim(),
                alTocar: () => alQuitar(tamano),
              ),
            ],
          ),
        BotonDeEnlace(texto: 'Agregar otro tamaño', alTocar: alAgregar),
      ],
    );
  }
}

/// La "✕" gris y redonda que quita un tamaño.
class _BotonDeQuitarTamano extends StatelessWidget {
  const _BotonDeQuitarTamano({required this.etiqueta, required this.alTocar});

  final String etiqueta;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      etiqueta: etiqueta,
      radio: 22,
      decoracion: const BoxDecoration(color: Colores.superficieHundida),
      child: const SizedBox(
        width: 44,
        height: 44,
        child: Icon(Icons.close_rounded, color: Colores.tinta, size: 20),
      ),
    );
  }
}
