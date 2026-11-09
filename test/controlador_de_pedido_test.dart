import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/controladores/controlador_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/simulados/datos_de_ejemplo.dart';

void main() {
  final payDeLimon = productosDeEjemplo[0]; // $45
  final esquite = productosDeEjemplo[5]; // $35

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
    expect(pedido.lineas, hasLength(2));
  });

  test('quitar la última pieza saca el producto del pedido', () {
    final pedido = ControladorDePedido()
      ..agregar(esquite)
      ..quitar(esquite);

    expect(pedido.estaVacio, isTrue);
  });

  test('avisa a quien escucha cada vez que cambia', () {
    final pedido = ControladorDePedido();
    var avisos = 0;
    pedido.addListener(() => avisos++);

    pedido.agregar(payDeLimon);
    pedido.vaciar();

    expect(avisos, 2);
  });
}
