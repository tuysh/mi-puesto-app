import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/datos/conexiones.dart';
import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/http/almacen_de_sesion_en_memoria.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/gasto.dart';
import 'package:mi_puesto/datos/modelos/presentacion.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/fechas.dart';

/// Prueba los repositorios `…Http` contra un servidor de verdad (API v2).
///
/// Normalmente se salta. Para correrla, levanta el backend en tu
/// computadora con los datos de `python manage.py sembrar_demo` recién
/// sembrados (en una base de datos que se pueda ensuciar: la prueba vende,
/// crea cosas y registra una cuenta, así que deja rastro) y ejecuta:
///
/// ```
/// SERVIDOR_DE_PRUEBA=http://127.0.0.1:8000 flutter test test/servidor_real_test.dart
/// ```
///
/// La cuenta sembrada es `mari@ejemplo.com` / `pay-de-limon`; el PIN de
/// Mari (dueña) es 1234 y el de Lupe (vende) es 1111.
void main() {
  final url = Platform.environment['SERVIDOR_DE_PRUEBA'];
  final razonParaSaltar = url == null
      ? 'Falta la variable SERVIDOR_DE_PRUEBA'
      : null;

  /// Conexiones nuevas, como un dispositivo que nunca ha iniciado sesión.
  Conexiones conectar() {
    return Conexiones.http(
      urlDelServidor: url!,
      almacen: AlmacenDeSesionEnMemoria(),
    );
  }

  /// Inicia sesión con la cuenta sembrada y entra como la persona llamada
  /// [nombre].
  Future<Conexiones> entrarComo(String nombre, String pin) async {
    final conexiones = conectar();
    final cuenta = await conexiones.sesion.iniciarSesion(
      correo: 'mari@ejemplo.com',
      contrasena: 'pay-de-limon',
    );
    final perfil = cuenta!.perfiles.firstWhere((p) => p.nombre == nombre);
    await conexiones.sesion.entrarComoPerfil(perfilId: perfil.id, pin: pin);
    return conexiones;
  }

  test('la cuenta sembrada entra y dice quiénes venden', () async {
    final conexiones = conectar();

    expect(await conexiones.sesion.consultarCuenta(), isNull);
    final sinEntrar = await conexiones.sesion.iniciarSesion(
      correo: 'mari@ejemplo.com',
      contrasena: 'otra-contraseña',
    );
    expect(sinEntrar, isNull);

    final cuenta = await conexiones.sesion.iniciarSesion(
      correo: 'mari@ejemplo.com',
      contrasena: 'pay-de-limon',
    );
    expect(cuenta!.tieneDueno, isTrue);
    expect(cuenta.perfilActivo, isNull);
    expect(cuenta.perfiles.map((perfil) => perfil.nombre), contains('Lupe'));

    // Sin escribir el PIN, casi todo responde `sin_perfil`.
    await expectLater(
      conexiones.catalogo.obtenerCatalogo(),
      throwsA(
        isA<ErrorDelServidor>().having(
          (e) => e.codigo,
          'codigo',
          CodigosDeError.sinPerfil,
        ),
      ),
    );

    final mari = cuenta.perfiles.firstWhere((perfil) => perfil.esDueno);
    final conPinMalo = await conexiones.sesion.entrarComoPerfil(
      perfilId: mari.id,
      pin: '0000',
    );
    expect(conPinMalo, isNull);
    final dentro = await conexiones.sesion.entrarComoPerfil(
      perfilId: mari.id,
      pin: '1234',
    );
    expect(dentro!.perfilActivo!.id, mari.id);

    await conexiones.sesion.cerrarSesion();
    expect(await conexiones.sesion.consultarCuenta(), isNull);
  }, skip: razonParaSaltar);

  test('una cuenta nueva crea a su dueña y empieza vacía', () async {
    final conexiones = conectar();
    // Un correo distinto en cada corrida, para poder repetir la prueba.
    final correo =
        'prueba-${DateTime.now().millisecondsSinceEpoch}@ejemplo.com';

    final cuenta = await conexiones.sesion.crearCuenta(
      nombreDelNegocio: 'Puesto de prueba',
      correo: correo,
      contrasena: 'una-clave-larga-y-rara',
    );
    expect(cuenta.tieneDueno, isFalse);

    final conDuena = await conexiones.sesion.crearDuena(
      nombre: 'Prueba',
      pin: '0412',
    );
    expect(conDuena.perfilActivo!.esDueno, isTrue);
    expect((await conexiones.catalogo.obtenerCatalogo()).productos, isEmpty);
    expect(await conexiones.caja.obtenerCajaAbierta(), isNull);
  }, skip: razonParaSaltar);

  test(
    'la dueña crea un producto con tamaños, lo cambia y lo desactiva',
    () async {
      final conexiones = await entrarComo('Mari', '1234');

      final creado = await conexiones.catalogo.guardarProducto(
        const Producto(
          id: '',
          nombre: 'Pozole de prueba',
          categoriaId: null,
          precio: null,
          presentaciones: [
            Presentacion(id: '', nombre: 'Chico', precio: Dinero.pesos(70)),
            Presentacion(id: '', nombre: 'Grande', precio: Dinero.pesos(95)),
          ],
        ),
      );
      expect(creado.esNuevo, isFalse);
      expect(creado.precio, isNull);
      expect(creado.presentaciones.length, 2);
      expect(creado.presentaciones.first.esNueva, isFalse);

      final sinHoy = await conexiones.catalogo.cambiarDisponibilidad(
        creado.id,
        false,
      );
      expect(sinHoy.disponible, isFalse);

      await conexiones.catalogo.desactivarProducto(creado.id);
      final catalogo = await conexiones.catalogo.obtenerCatalogo();
      expect(catalogo.productos.any((p) => p.id == creado.id), isFalse);
    },
    skip: razonParaSaltar,
  );

  test('se vende, se edita y se cancela con la caja abierta', () async {
    final conexiones = await entrarComo('Mari', '1234');
    if (await conexiones.caja.obtenerCajaAbierta() == null) {
      await conexiones.caja.abrirCaja(const Dinero.pesos(500));
    }

    final catalogo = await conexiones.catalogo.obtenerCatalogo();
    final sencillo = catalogo.productos.firstWhere(
      (producto) => !producto.tieneTamanos && producto.disponible,
    );
    final conTamanos = catalogo.productos.firstWhere(
      (producto) => producto.tieneTamanos && producto.disponible,
    );

    final venta = await conexiones.ventas.registrarVenta(
      lineas: [
        LineaPorCobrar(productoId: sencillo.id, cantidad: 1),
        LineaPorCobrar(
          productoId: conTamanos.id,
          presentacionId: conTamanos.presentaciones.first.id,
          cantidad: 2,
        ),
      ],
      metodoDePago: MetodoDePago.efectivo,
      montoRecibido: const Dinero.pesos(1000),
      nota: 'Prueba',
    );
    expect(
      venta.total,
      sencillo.precio! + conTamanos.presentaciones.first.precio * 2,
    );
    expect(venta.cambio, const Dinero.pesos(1000) - venta.total);

    final delDia = await conexiones.ventas.obtenerVentasDelDia(hoy());
    expect(delDia.ventas.any((v) => v.id == venta.id), isTrue);

    final editada = await conexiones.ventas.editarVenta(
      venta.id,
      lineas: [LineaPorCobrar(productoId: sencillo.id, cantidad: 2)],
      nota: 'Prueba editada',
    );
    expect(editada.total, sencillo.precio! * 2);
    expect(editada.sePuedeCambiar, isTrue);
    expect(editada.eventos.single.tipo, TipoDeEvento.edicion);

    final cancelada = await conexiones.ventas.cancelarVenta(venta.id);
    expect(cancelada.estaCancelada, isTrue);
    expect(cancelada.sePuedeCambiar, isFalse);
  }, skip: razonParaSaltar);

  test('quien solo vende no puede lo que es de la dueña', () async {
    final conexiones = await entrarComo('Lupe', '1111');

    await expectLater(
      conexiones.perfiles.obtenerPerfiles(),
      throwsA(
        isA<ErrorDelServidor>().having((e) => e.codigo, 'codigo', 'solo_dueno'),
      ),
    );
    // Sí puede ver el catálogo y sus propias ventas.
    expect((await conexiones.catalogo.obtenerCatalogo()).productos, isNotEmpty);
    final ventas = await conexiones.ventas.obtenerVentasDelDia(hoy());
    expect(ventas.cuantas, ventas.ventas.where((v) => !v.estaCancelada).length);
  }, skip: razonParaSaltar);

  test('gastos, categorías y resumen', () async {
    final conexiones = await entrarComo('Mari', '1234');

    final categoria = await conexiones.categoriasDeGastos.crearCategoria(
      'Prueba ${DateTime.now().millisecondsSinceEpoch}',
    );
    final gasto = await conexiones.gastos.guardarGasto(
      Gasto(
        id: '',
        concepto: 'Gasto de prueba',
        monto: const Dinero.pesos(12),
        fecha: hoy(),
        categoriaId: categoria.id,
        deCaja: false,
      ),
    );
    expect(gasto.esNuevo, isFalse);
    expect(gasto.editable, isTrue);

    final deHoy = await conexiones.gastos.obtenerGastos(
      desde: hoy(),
      hasta: hoy(),
      categoriaId: categoria.id,
    );
    expect(deHoy.gastos.single.concepto, 'Gasto de prueba');
    expect(deHoy.total, const Dinero.pesos(12));

    final resumen = await conexiones.resumen.obtenerResumen(
      periodo: Periodo.semana,
      fecha: hoy(),
      secciones: SeccionDeResumen.values.toSet(),
    );
    expect(resumen.desde, lunesDe(hoy()));
    expect(resumen.porDia.length, 7);
    expect(
      resumen.totales.utilidad,
      resumen.totales.vendido - resumen.totales.gastos,
    );
    expect(
      resumen.gastosPorCategoria.any((g) => g.nombre == categoria.nombre),
      isTrue,
    );

    await conexiones.gastos.eliminarGasto(gasto.id);
    await conexiones.categoriasDeGastos.eliminarCategoria(categoria.id);
  }, skip: razonParaSaltar);
}
