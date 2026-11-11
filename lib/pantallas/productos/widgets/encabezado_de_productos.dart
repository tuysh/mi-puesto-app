import 'package:flutter/material.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_contorno.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_volver.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/pantallas/categorias/pantalla_de_categorias.dart';

/// Encabezado de "Productos" en tablet: la flecha para volver a "Más", el
/// título, cuántos productos hay (y cuántos hay hoy) y los botones
/// "Categorías" y "Nuevo producto".
class EncabezadoDeProductos extends StatelessWidget {
  const EncabezadoDeProductos({
    super.key,
    required this.cuantosProductos,
    required this.cuantosHayHoy,
    required this.alCrear,
  });

  final int cuantosProductos;
  final int cuantosHayHoy;
  final VoidCallback alCrear;

  @override
  Widget build(BuildContext context) {
    final palabra = cuantosProductos == 1 ? 'producto' : 'productos';

    return Row(
      spacing: 10,
      children: [
        BotonDeVolver(alTocar: () => cerrarPantalla(context)),
        Text('Productos', style: Tipografia.titulo(34)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '$cuantosProductos $palabra · $cuantosHayHoy hay hoy',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Tipografia.texto(16, color: Colores.tintaSuave),
            ),
          ),
        ),
        BotonDeContorno(
          texto: 'Categorías',
          alto: 48,
          tamanoDeTexto: 16,
          alTocar: () => abrirPantalla(context, const PantallaDeCategorias()),
        ),
        BotonPrincipal(
          texto: 'Nuevo producto',
          icono: Icons.add_rounded,
          alto: 48,
          tamanoDeTexto: 16,
          alTocar: alCrear,
        ),
      ],
    );
  }
}
