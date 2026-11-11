import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';

/// Un renglón de una [ListaEnTarjeta]: un título con un detalle gris
/// debajo y, a la derecha, un monto. Si se puede tocar lleva una flechita.
///
/// ```dart
/// FilaDeLista(
///   titulo: 'Tanque de gas',
///   detalle: 'Lun 3 · Gas · de la caja',
///   monto: '$180',
///   alTocar: () => …,
/// )
/// ```
class FilaDeLista extends StatelessWidget {
  const FilaDeLista({
    super.key,
    required this.titulo,
    this.detalle,
    this.bajoElTitulo,
    this.alInicio,
    this.juntoAlTitulo,
    this.monto,
    this.montoTachado = false,
    this.alTocar,
    this.altoMinimo = 62,
    this.tamanoDeTitulo = 16,
  });

  final String titulo;

  /// Renglón gris debajo del título.
  final String? detalle;

  /// Lo que va debajo del título cuando no es un simple texto: por
  /// ejemplo, una pastilla "Cuadró".
  final Widget? bajoElTitulo;

  /// Lo que va antes del título: un avatar, la imagen de un producto…
  final Widget? alInicio;

  /// Lo que va pegado a la derecha del título, por ejemplo una pastilla
  /// "Cancelada".
  final Widget? juntoAlTitulo;

  /// El monto ya convertido a texto, por ejemplo `$180`.
  final String? monto;

  /// Con `true` el monto va tachado y en gris: ya no cuenta.
  final bool montoTachado;

  /// Si es `null`, el renglón no se toca y no lleva flechita.
  final VoidCallback? alTocar;

  final double altoMinimo;
  final double tamanoDeTitulo;

  @override
  Widget build(BuildContext context) {
    final detalle = this.detalle;
    final monto = this.monto;
    final sePuedeTocar = alTocar != null;

    return InkWell(
      onTap: alTocar,
      child: Container(
        constraints: BoxConstraints(minHeight: altoMinimo),
        padding: EdgeInsets.fromLTRB(16, 8, sePuedeTocar ? 12 : 16, 8),
        child: Row(
          spacing: 10,
          children: [
            ?alInicio,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Flexible(
                        child: Text(
                          titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Tipografia.texto(
                            tamanoDeTitulo,
                            peso: 800,
                            altura: 1.15,
                          ),
                        ),
                      ),
                      ?juntoAlTitulo,
                    ],
                  ),
                  ?bajoElTitulo,
                  if (detalle != null)
                    Text(
                      detalle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Tipografia.texto(
                        14,
                        color: Colores.tintaSuave,
                        altura: 1.15,
                      ),
                    ),
                ],
              ),
            ),
            if (monto != null)
              Text(
                monto,
                style:
                    Tipografia.cifra(
                      19,
                      color: montoTachado ? Colores.tintaSuave : Colores.tinta,
                    ).copyWith(
                      decoration: montoTachado
                          ? TextDecoration.lineThrough
                          : null,
                    ),
              ),
            if (sePuedeTocar)
              const Icon(
                Icons.chevron_right_rounded,
                color: Colores.tintaSuave,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
