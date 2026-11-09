/// Una cantidad de dinero.
///
/// Se guarda en centavos (números enteros) para que las sumas sean exactas:
/// con decimales, 0.1 + 0.2 no da exactamente 0.3.
class Dinero implements Comparable<Dinero> {
  const Dinero.centavos(this.centavos);

  const Dinero.pesos(int pesos) : centavos = pesos * 100;

  static const cero = Dinero.centavos(0);

  final int centavos;

  bool get esCero => centavos == 0;
  bool get esNegativo => centavos < 0;

  /// La misma cantidad, pero sin signo.
  Dinero get absoluto => Dinero.centavos(centavos.abs());

  Dinero operator +(Dinero otro) => Dinero.centavos(centavos + otro.centavos);
  Dinero operator -(Dinero otro) => Dinero.centavos(centavos - otro.centavos);
  Dinero operator *(int veces) => Dinero.centavos(centavos * veces);

  bool operator <(Dinero otro) => centavos < otro.centavos;
  bool operator >(Dinero otro) => centavos > otro.centavos;
  bool operator >=(Dinero otro) => centavos >= otro.centavos;

  @override
  int compareTo(Dinero otro) => centavos.compareTo(otro.centavos);

  @override
  bool operator ==(Object other) {
    return other is Dinero && other.centavos == centavos;
  }

  @override
  int get hashCode => centavos.hashCode;

  @override
  String toString() => 'Dinero($centavos centavos)';
}

/// Suma una lista de cantidades.
Dinero sumarDinero(Iterable<Dinero> cantidades) {
  return cantidades.fold(Dinero.cero, (suma, cantidad) => suma + cantidad);
}
