import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/controladores/controlador_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/simulados/datos_de_ejemplo.dart';

void main() {
  final payDeLimon = productosDeEjemplo[0]; // $45
  final esquite = productosDeEjemplo[5]; // $35
  final horchata = productosDeEjemplo[9]; // Chica $15, Grande $25
  final chica = horchata.presentaciones[0];
  final grande = horchata.presentaciones[1];

  test('un pedido nuevo está vacío', () {
    final pedido = ControladorDePedido();

    expect(pedido.estaVacio, isTrue);
    expect(pedido.piezas, 0);
    expect(pedido.total, Dinero.cero);
  });

  test('agregar suma piezas y dinero', () {
    final pedido = ControladorDePedido()
      ..agregar(payDeLimon)
      ..agregar(payDeLimon)
      ..agregar(esquite);

    expect(pedido.cantidadDe(payDeLimon), 2);
    expect(pedido.piezas, 3);
    expect(pedido.total, const Dinero.pesos(125));
    expect(pedido.lineas.length, 2);
  });

  test('quitar la última pieza saca el producto del pedido', () {
    final pedido = ControladorDePedido()
      ..agregar(payDeLimon)
      ..quitar(payDeLimon);

    expect(pedido.estaVacio, isTrue);
    expect(pedido.cantidadDe(payDeLimon), 0);
  });

  test('cada tamaño de un producto es su propio renglón', () {
    final pedido = ControladorDePedido()
      ..agregar(horchata, presentacion: chica)
      ..agregar(horchata, presentacion: grande)
      ..agregar(horchata, presentacion: grande);

    expect(pedido.lineas.length, 2);
    expect(pedido.cantidadDe(horchata, presentacion: chica), 1);
    expect(pedido.cantidadDe(horchata, presentacion: grande), 2);
    // La tesela del producto suma todos sus tamaños.
    expect(pedido.piezasDe(horchata), 3);
    expect(pedido.total, const Dinero.pesos(65));
    expect(pedido.lineas.last.nombreCompleto, 'Horchata grande');
  });

  test(
    'ponerCantidad deja la cantidad exacta, y con cero quita el renglón',
    () {
      final pedido = ControladorDePedido()
        ..ponerCantidad(horchata, 4, presentacion: chica)
        ..ponerCantidad(horchata, 1, presentacion: grande);
      expect(pedido.piezas, 5);

      pedido.ponerCantidad(horchata, 0, presentacion: chica);
      expect(pedido.lineas.single.presentacion, grande);
    },
  );

  test('avisa a quien lo escucha cada vez que cambia', () {
    final pedido = ControladorDePedido();
    var avisos = 0;
    pedido.addListener(() => avisos++);

    pedido
      ..agregar(esquite)
      ..quitar(esquite)
      ..vaciar();

    expect(avisos, 3);
  });
}
