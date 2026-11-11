import 'package:flutter/painting.dart';

/// Un color de fondo y el color de texto ("tinta") que se lee bien sobre él.
class ParDeColores {
  const ParDeColores({required this.fondo, required this.tinta});

  final Color fondo;
  final Color tinta;
}

/// Todos los colores fijos de la aplicación.
abstract final class Colores {
  static const fondo = Color(0xFFFBF6F3);
  static const superficie = Color(0xFFFFFFFF);
  static const superficieHundida = Color(0xFFF1E7E9);

  static const tinta = Color(0xFF24181F);
  static const tintaSuave = Color(0xFF6B5A63);

  static const acento = Color(0xFFC42A62);
  static const acentoSuave = Color(0xFFFBE3EB);

  static const borde = Color(0xFFEADFE1);
  static const bordeDeCampo = Color(0xFFA99AA0);
  static const bordePunteado = Color(0xFFC9B8BD);

  /// La tinta al 12 %: se usa en las sombras "duras" (sin difuminar).
  static const sombra = Color(0x1F24181F);

  static const barraDeGanancia = Color(0xFF3FA36F);

  /// Verde: ganancias, cambio y avisos de que todo salió bien.
  static const exito = ParDeColores(
    fondo: Color(0xFFD9F2E3),
    tinta: Color(0xFF145A3A),
  );

  /// Ámbar: avisos que piden atención (por ejemplo, falta dinero en caja).
  static const alerta = ParDeColores(
    fondo: Color(0xFFFFEDB8),
    tinta: Color(0xFF6E4E00),
  );

  /// Gris: lo que no tiene categoría (un producto, un gasto).
  static const sinCategoria = ParDeColores(
    fondo: superficieHundida,
    tinta: tintaSuave,
  );
}

/// Colores pastel para distinguir categorías y personas.
abstract final class Pasteles {
  static const rosa = ParDeColores(
    fondo: Color(0xFFF9D3DE),
    tinta: Color(0xFF8A2149),
  );
  static const amarillo = ParDeColores(
    fondo: Color(0xFFFCE7A6),
    tinta: Color(0xFF734A00),
  );
  static const azul = ParDeColores(
    fondo: Color(0xFFCFE4F7),
    tinta: Color(0xFF0F4C7A),
  );
  static const lila = ParDeColores(
    fondo: Color(0xFFE4D8F7),
    tinta: Color(0xFF5A2F8A),
  );
  static const verde = Colores.exito;

  static const todos = [rosa, verde, azul, amarillo, lila];

  /// Devuelve un pastel para la posición [indice]; al acabarse, se repiten.
  static ParDeColores paraIndice(int indice) => todos[indice % todos.length];
}
