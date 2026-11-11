import 'package:flutter/widgets.dart';
import 'package:mi_puesto/datos/modelos/presentacion.dart';
import 'package:mi_puesto/nucleo/formato/formato_dinero.dart';

/// Un tamaño mientras se edita en el formulario de un producto: los dos
/// campos donde se escriben su nombre y su precio.
class TamanoEnEdicion {
  /// Un renglón en blanco, para un tamaño que todavía no existe.
  TamanoEnEdicion.nuevo()
    : id = '',
      nombre = TextEditingController(),
      precio = TextEditingController();

  /// Un renglón con los datos de un tamaño ya guardado.
  TamanoEnEdicion.de(Presentacion presentacion)
    : id = presentacion.id,
      nombre = TextEditingController(text: presentacion.nombre),
      precio = TextEditingController(
        text: formatearMontoEditable(presentacion.precio),
      );

  /// El `id` del tamaño en el servidor; vacío si es nuevo. Hay que
  /// conservarlo: con él el servidor actualiza ese tamaño en vez de crear
  /// otro.
  final String id;

  final TextEditingController nombre;
  final TextEditingController precio;

  /// Lo escrito, convertido a un tamaño; `null` si falta el nombre o el
  /// precio no es un número.
  Presentacion? leer() {
    final nombreLimpio = nombre.text.trim();
    final precioLeido = leerDinero(precio.text);
    if (nombreLimpio.isEmpty || precioLeido == null) return null;

    return Presentacion(id: id, nombre: nombreLimpio, precio: precioLeido);
  }

  /// Libera los dos campos. Hay que llamarlo al quitar el renglón o al
  /// cerrar el formulario.
  void liberar() {
    nombre.dispose();
    precio.dispose();
  }
}
