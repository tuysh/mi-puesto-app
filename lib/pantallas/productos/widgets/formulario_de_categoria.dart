import 'package:flutter/material.dart';
import 'package:mi_puesto/app/dependencias.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/nucleo/avisos.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';
import 'package:mi_puesto/nucleo/tema/tipografia.dart';
import 'package:mi_puesto/nucleo/widgets/boton_de_enlace.dart';
import 'package:mi_puesto/nucleo/widgets/boton_principal.dart';
import 'package:mi_puesto/nucleo/widgets/campo_de_texto.dart';
import 'package:mi_puesto/nucleo/widgets/campo_etiquetado.dart';
import 'package:mi_puesto/nucleo/widgets/columna_con_pie.dart';
import 'package:mi_puesto/pantallas/productos/elegir_emoji.dart';
import 'package:mi_puesto/pantallas/productos/widgets/boton_de_emoji.dart';
import 'package:mi_puesto/pantallas/productos/widgets/selector_de_color.dart';

/// El formulario para crear o editar una categoría: emoji, nombre y color.
class FormularioDeCategoria extends StatefulWidget {
  const FormularioDeCategoria({
    super.key,
    required this.categoria,
    required this.alGuardar,
    this.alEliminar,
  });

  /// La categoría a editar, o una en blanco (`Categoria.nueva`) para crear.
  final Categoria categoria;

  /// Se llama después de guardar, con la categoría tal como quedó.
  final ValueChanged<Categoria> alGuardar;

  /// Se llama al tocar "Eliminar categoría". Si es `null`, ese botón no se
  /// muestra (por ejemplo, en una categoría que aún no se ha guardado).
  final VoidCallback? alEliminar;

  @override
  State<FormularioDeCategoria> createState() =>
      _EstadoDeFormularioDeCategoria();
}

class _EstadoDeFormularioDeCategoria extends State<FormularioDeCategoria> {
  late final _nombre = TextEditingController(text: widget.categoria.nombre);
  late String _emoji = widget.categoria.emoji;
  late ParDeColores _colores = widget.categoria.colores;

  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _cambiarEmoji() async {
    final emoji = await elegirEmoji(
      context,
      emojiActual: _emoji,
      nombreDelProducto: _nombre.text.trim(),
      fondo: _colores.fondo,
    );
    if (emoji == null) return;

    setState(() => _emoji = emoji);
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      mostrarAviso(context, 'Escribe el nombre de la categoría');
      return;
    }

    // Se parte de `widget.categoria` para conservar su `id`.
    final cambiada = widget.categoria.copiarCon(
      nombre: nombre,
      emoji: _emoji,
      colores: _colores,
    );

    final catalogo = Dependencias.de(context).catalogo;
    setState(() => _guardando = true);
    try {
      final guardada = await catalogo.guardarCategoria(cambiada);
      if (!mounted) return;

      mostrarAviso(context, 'Categoría guardada');
      widget.alGuardar(guardada);
    } catch (error) {
      if (mounted) {
        mostrarAvisoDeError(
          context,
          error,
          siNoHayExplicacion: 'No se pudo guardar la categoría',
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _nombre.text.trim();

    return ColumnaConPie(
      espacio: 14,
      pie: BotonPrincipal(
        texto: 'Guardar categoría',
        alto: 58,
        tamanoDeTexto: 20,
        alTocar: _guardando ? null : _guardar,
      ),
      children: [
        Row(
          spacing: 14,
          children: [
            BotonDeEmoji(
              emoji: _emoji,
              fondo: _colores.fondo,
              alTocar: _cambiarEmoji,
            ),
            Expanded(
              child: Text(
                nombre.isEmpty ? 'Nueva categoría' : nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Tipografia.titulo(24),
              ),
            ),
          ],
        ),
        CampoEtiquetado(
          etiqueta: 'Nombre',
          child: CampoDeTexto(
            controlador: _nombre,
            sugerencia: 'Ej. Helados',
            // Redibuja para actualizar el título de arriba.
            alCambiar: (_) => setState(() {}),
          ),
        ),
        CampoEtiquetado(
          etiqueta: 'Color',
          child: SelectorDeColor(
            opciones: Pasteles.todos,
            elegido: _colores,
            alElegir: (colores) => setState(() => _colores = colores),
          ),
        ),
        Text(
          'Los productos de esta categoría se pintan de este color al vender.',
          style: Tipografia.texto(14, peso: 600, color: Colores.tintaSuave),
        ),
        if (widget.alEliminar != null)
          Align(
            alignment: Alignment.centerLeft,
            child: BotonDeEnlace(
              texto: 'Eliminar categoría',
              icono: Icons.delete_outline_rounded,
              alTocar: widget.alEliminar,
            ),
          ),
      ],
    );
  }
}
