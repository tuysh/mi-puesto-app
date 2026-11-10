import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/datos/conexiones.dart';
import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/http/almacen_de_sesion_en_memoria.dart';
import 'package:mi_puesto/datos/modelos/caja.dart';
import 'package:mi_puesto/datos/modelos/categoria.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/estado_de_acceso.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/modelos/reporte.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Prueba los repositorios `…Http` contra un servidor de verdad.
///
/// Normalmente se salta. Para correrla, levanta el backend en tu
/// computadora con los datos de `python manage.py sembrar_demo` (en una
/// base de datos que se pueda ensuciar) y ejecuta:
///
/// ```
/// SERVIDOR_DE_PRUEBA=http://127.0.0.1:8000 flutter test test/servidor_real_test.dart
/// ```
void main() {
  final url = Platform.environment['SERVIDOR_DE_PRUEBA'];
  final razonParaSaltar = url == null
      ? 'Falta la variable SERVIDOR_DE_PRUEBA'
      : null;

  Conexiones conectar() {
    return Conexiones.http(
      urlDelServidor: url!,
      almacen: AlmacenDeSesionEnMemoria(),
    );
  }

  test('la cuenta de ejemplo: entrar, vender, reportes y caja', () async {
    final conexiones = conectar();
    final sesion = conexiones.sesion;

    // Cuenta y PIN.
    expect(await sesion.consultarAcceso(), EstadoDeAcceso.sinSesion);
    expect(
      await sesion.iniciarSesion(
        correo: 'mari@ejemplo.com',
        contrasena: 'no-es-esta',
      ),
      isFalse,
    );
    expect(
      await sesion.iniciarSesion(
        correo: 'Mari@Ejemplo.com',
        contrasena: 'pay-de-limon',
      ),
      isTrue,
    );
    expect(await sesion.consultarAcceso(), EstadoDeAcceso.listo);
    expect((await sesion.obtenerPuesto()).nombre, 'Puesto Doña Mari');
    expect(await sesion.validarPin('0000'), isFalse);
    expect(await sesion.validarPin('1234'), isTrue);

    // ¿Quién vende?
    final vendedores = await conexiones.vendedores.obtenerVendedores();
    expect(vendedores.map((v) => v.nombre), containsAll(['Mari', 'Lupe']));
    final mari = vendedores.firstWhere((v) => v.nombre == 'Mari');

    // Catálogo.
    final categorias = await conexiones.catalogo.obtenerCategorias();
    final productos = await conexiones.catalogo.obtenerProductos();
    expect(categorias.first.nombre, 'Postres');
    expect(identical(categorias.first.colores, Pasteles.rosa), isTrue);
    final pay = productos.firstWhere((p) => p.nombre == 'Pay de limón');
    final esquite = productos.firstWhere((p) => p.nombre == 'Elote en vaso');
    expect(pay.nombreCorto, 'Pay limón');
    expect(pay.precio, const Dinero.pesos(45));
    expect(pay.costo, const Dinero.pesos(18));

    // Vender: dos pays y un esquite, paga con $200.
    final lineas = [
      LineaDePedido(producto: pay, cantidad: 2),
      LineaDePedido(producto: esquite, cantidad: 1),
    ];
    final venta = await conexiones.ventas.registrarVenta(
      lineas: lineas,
      pagoCon: const Dinero.pesos(200),
      vendedor: mari,
    );
    expect(venta.total, const Dinero.pesos(125));
    expect(venta.cambio, const Dinero.pesos(75));

    // Pago exacto.
    final exacta = await conexiones.ventas.registrarVenta(
      lineas: lineas,
      pagoCon: const Dinero.pesos(125),
      vendedor: mari,
    );
    expect(exacta.cambio, Dinero.cero);

    // Hoy, antes y después de anular la venta exacta.
    final antes = await conexiones.reportes.obtenerResumenDeHoy();
    await conexiones.ventas.anularVenta(exacta.id);
    final despues = await conexiones.reportes.obtenerResumenDeHoy();
    expect(antes.vendido - despues.vendido, const Dinero.pesos(125));
    expect(despues.numeroDeVentas, antes.numeroDeVentas - 1);
    expect(despues.masVendidos, isNotEmpty);
    expect(despues.ventasPorVendedor.first.nombre, isNotEmpty);

    // Reportes: cada periodo suma lo mismo en la gráfica que en el total.
    for (final periodo in Periodo.values) {
      final reporte = await conexiones.reportes.obtenerReporte(periodo);
      expect(
        sumarDinero(reporte.tramos.map((tramo) => tramo.vendido)),
        reporte.vendido,
        reason: 'gráfica de ${periodo.name}',
      );
      expect(reporte.tramos.where((t) => t.esActual), hasLength(1));
      expect(reporte.ventasPorCategoria, isNotEmpty);
    }
    final semana = await conexiones.reportes.obtenerReporte(Periodo.semana);
    expect(semana.tramos.map((t) => t.etiqueta).join(), 'LMMJVSD');

    // Caja: cerrar la que está abierta y abrir otra.
    final cuenta = await conexiones.caja.obtenerCuentaDeCaja();
    expect(cuenta!.fondoInicial, const Dinero.pesos(500));
    expect(cuenta.vendidoEnEfectivo >= const Dinero.pesos(125), isTrue);
    await conexiones.caja.cerrarCaja(
      CierreDeCaja(contado: cuenta.debeHaber, nota: 'prueba'),
    );
    expect(await conexiones.caja.obtenerCuentaDeCaja(), isNull);
    final nueva = await conexiones.caja.abrirCaja(const Dinero.centavos(30050));
    expect(nueva.fondoInicial, const Dinero.centavos(30050));
    expect(nueva.vendidoEnEfectivo, Dinero.cero);

    await sesion.cerrarSesion();
    expect(await sesion.consultarAcceso(), EstadoDeAcceso.sinSesion);
  }, skip: razonParaSaltar);

  test('una cuenta nueva: PIN, personas, categorías y productos', () async {
    final conexiones = conectar();
    final sesion = conexiones.sesion;
    final correo =
        'prueba-${DateTime.now().microsecondsSinceEpoch}@ejemplo.com';

    // Una contraseña débil trae la explicación del servidor.
    await expectLater(
      sesion.crearCuenta(correo: correo, contrasena: '12345678'),
      throwsA(
        isA<ErrorDelServidor>().having((e) => e.mensaje, 'mensaje', isNotEmpty),
      ),
    );

    await sesion.crearCuenta(correo: correo, contrasena: 'tostilocos-con-todo');
    expect(await sesion.consultarAcceso(), EstadoDeAcceso.faltaElPin);
    expect((await sesion.obtenerPuesto()).nombre, 'Mi puesto');
    await sesion.guardarPin('0123');
    expect(await sesion.consultarAcceso(), EstadoDeAcceso.listo);
    expect(await sesion.validarPin('0123'), isTrue);

    // El mismo correo no se puede registrar dos veces.
    await expectLater(
      conectar().sesion.crearCuenta(
        correo: correo,
        contrasena: 'tostilocos-con-todo',
      ),
      throwsA(
        isA<ErrorDelServidor>().having(
          (e) => e.mensaje,
          'mensaje',
          'Ya hay una cuenta con ese correo.',
        ),
      ),
    );

    // Personas.
    expect(await conexiones.vendedores.obtenerVendedores(), isEmpty);
    final chuy = await conexiones.vendedores.agregarVendedor('Chuy');
    expect(
      (await conexiones.vendedores.obtenerVendedores()).single.id,
      chuy.id,
    );

    // Categorías: crear, editar y que la segunda quede después.
    final catalogo = conexiones.catalogo;
    expect(await catalogo.obtenerCategorias(), isEmpty);
    final frutas = await catalogo.guardarCategoria(
      const Categoria.nueva().copiarCon(
        nombre: 'Frutas',
        emoji: '🍓',
        colores: Pasteles.verde,
      ),
    );
    expect(frutas.esNueva, isFalse);
    await catalogo.guardarCategoria(
      const Categoria.nueva().copiarCon(nombre: 'Aguas', emoji: '🥤'),
    );
    final cambiada = await catalogo.guardarCategoria(
      frutas.copiarCon(nombre: 'Fruta picada', colores: Pasteles.lila),
    );
    expect(cambiada.id, frutas.id);
    final categorias = await catalogo.obtenerCategorias();
    expect(categorias.map((c) => c.nombre), ['Fruta picada', 'Aguas']);
    expect(identical(categorias.first.colores, Pasteles.lila), isTrue);

    // Productos: crear, ocultar y vender.
    final nombreLargo = 'Mango con chile, limón y chamoy del bueno';
    final mango = await catalogo.guardarProducto(
      Producto.nuevo(categoriaId: frutas.id).copiarCon(
        nombre: nombreLargo,
        nombreCorto: nombreLargo,
        emoji: '🥭',
        precio: const Dinero.centavos(4050),
        costo: const Dinero.pesos(15),
      ),
    );
    expect(mango.esNuevo, isFalse);
    expect(mango.nombreCorto, nombreLargo);
    expect(mango.precio, const Dinero.centavos(4050));
    final oculto = await catalogo.guardarProducto(
      mango.copiarCon(nombreCorto: 'Mango', aLaVenta: false),
    );
    expect(oculto.aLaVenta, isFalse);
    expect((await catalogo.obtenerProductos()).single.nombreCorto, 'Mango');

    // Una categoría con productos no se puede eliminar.
    await expectLater(
      catalogo.eliminarCategoria(frutas.id),
      throwsA(isA<ErrorDelServidor>().having((e) => e.codigo, 'codigo', 409)),
    );

    final venta = await conexiones.ventas.registrarVenta(
      lineas: [LineaDePedido(producto: oculto, cantidad: 3)],
      pagoCon: const Dinero.pesos(200),
      vendedor: chuy,
    );
    expect(venta.total, const Dinero.centavos(12150));
    expect(venta.cambio, const Dinero.centavos(7850));

    // Sin caja abierta no hay cuenta; la venta se pudo hacer igual.
    expect(await conexiones.caja.obtenerCuentaDeCaja(), isNull);

    final hoy = await conexiones.reportes.obtenerResumenDeHoy();
    expect(hoy.vendido, const Dinero.centavos(12150));
    expect(hoy.masVendidos.single.piezas, 3);
    expect(hoy.masVendidos.single.productoId, mango.id);
    final dia = await conexiones.reportes.obtenerReporte(Periodo.dia);
    expect(dia.tramos.single.vendido, const Dinero.centavos(12150));
    expect(dia.ventasPorCategoria.single.categoria.nombre, 'Fruta picada');
  }, skip: razonParaSaltar);
}
