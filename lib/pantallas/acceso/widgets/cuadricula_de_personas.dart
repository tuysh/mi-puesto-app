import 'package:flutter/material.dart';
import 'package:mi_puesto/datos/modelos/perfil.dart';
import 'package:mi_puesto/pantallas/acceso/widgets/tarjeta_de_persona.dart';

/// Cuadrícula de dos columnas con una tarjeta por persona.
class CuadriculaDePersonas extends StatelessWidget {
  const CuadriculaDePersonas({
    super.key,
    required this.perfiles,
    required this.alElegir,
  });

  final List<Perfil> perfiles;
  final ValueChanged<Perfil> alElegir;

  @override
  Widget build(BuildContext context) {
    return GridView(
      // Deja sitio a las sombras de las tarjetas de la última fila.
      padding: const EdgeInsets.only(bottom: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 168,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      children: [
        for (final perfil in perfiles)
          TarjetaDePersona(
            nombre: perfil.nombre,
            inicial: perfil.inicial,
            rol: perfil.esDueno ? 'Dueña' : 'Vende',
            colores: perfil.colores,
            alTocar: () => alElegir(perfil),
          ),
      ],
    );
  }
}
