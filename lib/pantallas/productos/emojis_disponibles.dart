/// Un conjunto de emojis del mismo tipo, con su nombre.
class GrupoDeEmojis {
  const GrupoDeEmojis({required this.nombre, required this.emojis});

  final String nombre;
  final List<String> emojis;
}

/// Los emojis que se pueden elegir para un producto, por tipo.
/// Para ofrecer más, basta con agregarlos a estas listas.
const gruposDeEmojis = [
  GrupoDeEmojis(
    nombre: 'Postres',
    emojis: [
      '🥧',
      '🍰',
      '🧁',
      '🍮',
      '🍧',
      '🍨',
      '🍦',
      '🍩',
      '🍪',
      '🎂',
      '🍫',
      '🥞',
    ],
  ),
  GrupoDeEmojis(
    nombre: 'Antojos',
    emojis: [
      '🌮',
      '🌽',
      '🌶️',
      '🍟',
      '🌭',
      '🍕',
      '🥪',
      '🌯',
      '🥙',
      '🍿',
      '🥜',
      '🧀',
    ],
  ),
  GrupoDeEmojis(
    nombre: 'Bebidas',
    emojis: [
      '🥤',
      '🥛',
      '🧃',
      '☕',
      '🍵',
      '🧋',
      '🍹',
      '🧊',
      '🍺',
      '🥥',
      '🍋',
      '🌺',
    ],
  ),
  GrupoDeEmojis(nombre: 'Dulces', emojis: ['🍬', '🍭', '🍡', '🍯', '🍫', '🍪']),
  GrupoDeEmojis(
    nombre: 'Frutas',
    emojis: [
      '🍓',
      '🥭',
      '🍉',
      '🍍',
      '🍌',
      '🍎',
      '🍇',
      '🍒',
      '🍑',
      '🥝',
      '🍊',
      '🍐',
    ],
  ),
];
