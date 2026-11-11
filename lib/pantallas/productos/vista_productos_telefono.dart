import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/nucleo/navegacion.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/encabezado_con_volver.dart';
import 'package:mi_puesto/nucleo/widgets/fila_de_lista_vacia.dart';
import 'package:mi_puesto/nucleo/widgets/lista_en_tarjeta.dart';
import 'package:mi_puesto/nucleo/widgets/texto_de_ayuda.dart';
import 'package:mi_puesto/pantallas/productos/cambiar_disponibilidad.dart';
import 'package:mi_puesto/pantallas/productos/pantalla_de_editar_producto.dart';
import 'package:mi_puesto/pantallas/productos/widgets/fila_de_producto_en_lista.dart';

/// "Productos" en teléfono: la lista con el interruptor "Hay hoy" de cada
/// uno. Al tocar un producto, el formulario se abre en una pantalla aparte.
class VistaProductosTelefono extends StatelessWidget {
  const VistaProductosTelefono({super.key});

  void _editar(BuildContext context, Producto producto) {
    abrirPantalla(context, PantallaDeEditarProducto(producto: producto));
  }

  @override
  Widget build(BuildContext context) {
    final catalogo = Dependencias.de(context).catalogo;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          const EncabezadoConVolver(titulo: 'Productos'),
          const TextoDeAyuda(
            'Apaga «Hay hoy» cuando se acabe algo: se sigue viendo al '
            'vender, pero no se puede agregar.',
            peso: 700,
          ),
          Expanded(
            // Se redibuja cuando cambia el catálogo.
            child: ListenableBuilder(
              listenable: catalogo,
              builder: (context, _) => SingleChildScrollView(
                child: ListaEnTarjeta(
                  children: [
                    if (catalogo.productos.isEmpty)
                      const FilaDeListaVacia(
                        'Todavía no tienes productos. Agrega el primero.',
                      ),
                    for (final producto in catalogo.productos)
                      FilaDeProductoEnLista(
                        producto: producto,
                        categoria: catalogo.categoriaDe(producto),
                        alTocar: () => _editar(context, producto),
                        alCambiarSiHayHoy: (hayHoy) => cambiarDisponibilidad(
                          context,
                          producto,
                          hayHoy: hayHoy,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          BotonPrincipal(
            texto: 'Nuevo producto',
            icono: Icons.add_rounded,
            alTocar: () => _editar(context, const Producto.nuevo()),
          ),
        ],
      ),
    );
  }
}
