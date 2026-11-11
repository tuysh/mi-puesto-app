import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/logo_del_puesto.dart';

/// La cabecera centrada de los tres pasos del registro ("Crea tu PIN",
/// "Repite el PIN", "¿Cómo te llamas?"): un cuadro con icono, en qué paso
/// se va, el título y un renglón de ayuda.
class EncabezadoDePaso extends StatelessWidget {
  const EncabezadoDePaso({
    super.key,
    required this.icono,
    required this.paso,
    required this.titulo,
    required this.ayuda,
    this.ayudaEsUnError = false,
  });

  final IconData icono;

  /// En cuál de los tres pasos se va: 1, 2 o 3.
  final int paso;

  final String titulo;
  final String ayuda;

  /// Con `true` la ayuda se pinta fuerte y en rosa: algo salió mal.
  final bool ayudaEsUnError;

  static const _pasosEnTotal = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LogoDelPuesto(tamano: 60, icono: icono),
        const SizedBox(height: 20),
        Text(
          'Paso $paso de $_pasosEnTotal',
          style: Tipografia.texto(14, peso: 800, color: Colores.tintaSuave),
        ),
        const SizedBox(height: 8),
        Text(titulo, textAlign: TextAlign.center, style: Tipografia.titulo(30)),
        const SizedBox(height: 8),
        // Alto fijo para dos renglones: así lo de abajo no brinca cuando
        // el texto cambia de largo.
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 46),
          child: Semantics(
            liveRegion: true,
            child: Text(
              ayuda,
              textAlign: TextAlign.center,
              style: Tipografia.texto(
                16,
                peso: ayudaEsUnError ? 800 : 600,
                color: ayudaEsUnError
                    ? Pasteles.rosa.tinta
                    : Colores.tintaSuave,
                altura: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
