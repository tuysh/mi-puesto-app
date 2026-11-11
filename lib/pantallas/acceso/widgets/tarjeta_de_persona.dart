import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/medidas.dart';
import 'package:mi_puesto/nucleo/tema/sombras.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/avatar_de_inicial.dart';
import 'package:mi_puesto/nucleo/widgets/caja_tocable.dart';

/// Tarjeta grande con la inicial, el nombre y el papel de una persona
/// ("Dueña" o "Vende"). Es la que se toca en "¿Quién vende hoy?".
class TarjetaDePersona extends StatelessWidget {
  const TarjetaDePersona({
    super.key,
    required this.nombre,
    required this.inicial,
    required this.rol,
    required this.colores,
    required this.alTocar,
  });

  final String nombre;
  final String inicial;

  /// El papel de la persona, ya como texto: "Dueña" o "Vende".
  final String rol;

  final ParDeColores colores;

  /// Si es `null`, la tarjeta solo se mira (es una muestra).
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    return CajaTocable(
      alTocar: alTocar,
      etiqueta: '$nombre, $rol',
      radio: Radios.tarjetaGrande,
      decoracion: BoxDecoration(
        color: Colores.superficie,
        boxShadow: Sombras.dura(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarDeInicial(inicial: inicial, colores: colores, tamano: 72),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Tipografia.texto(19, peso: 800, altura: 1.2),
            ),
          ),
          Text(
            rol,
            style: Tipografia.texto(13, color: Colores.tintaSuave, altura: 1.2),
          ),
        ],
      ),
    );
  }
}
