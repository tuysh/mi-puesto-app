import 'package:flutter_test/flutter_test.dart';
import 'package:mi_puesto/datos/conexiones.dart';
import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';
import 'package:mi_puesto/nucleo/fechas.dart';

/// El servidor simulado sigue las mismas reglas que el de verdad (ver
/// `docs/api-v2.md` en el backend). Aquí se revisan las que más importan:
/// quién puede hacer qué, la cuenta de la caja y el resumen.
void main() {
  // En el negocio de ejemplo: Mari (dueña, PIN 1234), Lupe (vende, PIN
  // 1111); el flan es el producto 3 ($35) y la horchata el 10, con tamaños
  // 101 (chica, $15) y 102 (grande, $25).
  const unFlan = [LineaPorCobrar(productoId: '3', cantidad: 1)];

  Future<Conexiones> entrarComo(String perfilId, String pin) async {
    final conexiones = Conexiones.simuladas(conSesionIniciada: true);
    await conexiones.sesion.entrarComoPerfil(perfilId: perfilId, pin: pin);
    return conexiones;
  }

  Future<Conexiones> entrarComoDuena() => entrarComo('1', '1234');
  Future<Conexiones> entrarComoQuienVende() => entrarComo('2', '1111');

  /// Espera que [accion] falle con el código de error [codigo].
  Future<void> esperarError(Future<Object?> accion, String codigo) {
    return expectLater(
      accion,
      throwsA(
        isA<ErrorDelServidor>().having((e) => e.codigo, 'codigo', codigo),
      ),
    );
  }

  test('sin escribir el PIN casi nada responde', () async {
    final conexiones = Conexiones.simuladas(conSesionIniciada: true);

    await esperarError(conexiones.catalogo.obtenerCatalogo(), 'sin_perfil');
  });

  test('un PIN incorrecto no deja entrar', () async {
    final conexiones = Conexiones.simuladas(conSesionIniciada: true);

    final cuenta = await conexiones.sesion.entrarComoPerfil(
      perfilId: '2',
      pin: '0000',
    );

    expect(cuenta, isNull);
  });

  test('quien solo vende no puede lo que es de la dueña', () async {
    final conexiones = await entrarComoQuienVende();

    await esperarError(conexiones.perfiles.obtenerPerfiles(), 'solo_dueno');
    await esperarError(
      conexiones.caja.abrirCaja(const Dinero.pesos(100)),
      'solo_dueno',
    );
    await esperarError(
      conexiones.gastos.obtenerGastos(desde: hoy(), hasta: hoy()),
      'solo_dueno',
    );

    // Sí puede ver el catálogo y saber que la caja está abierta, pero sin
    // sus montos.
    expect((await conexiones.catalogo.obtenerCatalogo()).productos.length, 14);
    final caja = await conexiones.caja.obtenerCajaAbierta();
    expect(caja!.abierta, isTrue);
    expect(caja.fondoInicial, Dinero.cero);
  });

  test('sin caja abierta no se vende', () async {
    final conexiones = Conexiones.simuladas(
      conSesionIniciada: true,
      conCajaAbierta: false,
    );
    await conexiones.sesion.entrarComoPerfil(perfilId: '1', pin: '1234');

    await esperarError(
      conexiones.ventas.registrarVenta(
        lineas: unFlan,
        metodoDePago: MetodoDePago.efectivo,
      ),
      'sin_caja',
    );
  });

  test(
    'una venta lleva los precios del servidor y calcula el cambio',
    () async {
      final conexiones = await entrarComoDuena();

      final venta = await conexiones.ventas.registrarVenta(
        lineas: const [
          LineaPorCobrar(productoId: '3', cantidad: 2),
          LineaPorCobrar(productoId: '10', presentacionId: '102', cantidad: 1),
        ],
        metodoDePago: MetodoDePago.efectivo,
        montoRecibido: const Dinero.pesos(100),
        nota: 'Sin hielo',
      );

      expect(venta.total, const Dinero.pesos(95));
      expect(venta.cambio, const Dinero.pesos(5));
      expect(venta.lineas.last.nombreCompleto, 'Horchata grande');
      expect(venta.nota, 'Sin hielo');
    },
  );

  test('un producto con tamaños exige decir cuál, y lo que no hay no se '
      'vende', () async {
    final conexiones = await entrarComoDuena();

    Future<Venta> vender(String productoId) {
      return conexiones.ventas.registrarVenta(
        lineas: [LineaPorCobrar(productoId: productoId, cantidad: 1)],
        metodoDePago: MetodoDePago.efectivo,
      );
    }

    await expectLater(
      vender('10'),
      throwsA(
        isA<ErrorDelServidor>().having(
          (e) => e.mensaje,
          'mensaje',
          'Elige el tamaño de Horchata.',
        ),
      ),
    );
    // El mango (producto 8) está marcado "hoy no hay".
    await expectLater(
      vender('8'),
      throwsA(
        isA<ErrorDelServidor>().having(
          (e) => e.mensaje,
          'mensaje',
          'Hoy no hay Mango.',
        ),
      ),
    );
  });

  test('quien vende solo ve sus ventas; la dueña, las de todos', () async {
    final conexiones = await entrarComoDuena();
    await conexiones.ventas.registrarVenta(
      lineas: unFlan,
      metodoDePago: MetodoDePago.efectivo,
    );

    // Entra Lupe en el mismo dispositivo y vende otra cosa.
    await conexiones.sesion.entrarComoPerfil(perfilId: '2', pin: '1111');
    final deLupe = await conexiones.ventas.registrarVenta(
      lineas: unFlan,
      metodoDePago: MetodoDePago.tarjeta,
    );
    final loQueVeLupe = await conexiones.ventas.obtenerVentasDelDia(hoy());
    expect(loQueVeLupe.cuantas, 1);
    expect(loQueVeLupe.ventas.single.id, deLupe.id);
    // Con tarjeta no hay monto recibido ni cambio.
    expect(deLupe.cambio, isNull);

    await conexiones.sesion.entrarComoPerfil(perfilId: '1', pin: '1234');
    final loQueVeMari = await conexiones.ventas.obtenerVentasDelDia(hoy());
    expect(loQueVeMari.cuantas, 2);
    expect(loQueVeMari.total, const Dinero.pesos(70));
  });

  test('una venta cancelada sigue en la lista, pero ya no suma', () async {
    final conexiones = await entrarComoDuena();
    final venta = await conexiones.ventas.registrarVenta(
      lineas: unFlan,
      metodoDePago: MetodoDePago.efectivo,
    );

    final cancelada = await conexiones.ventas.cancelarVenta(venta.id);
    expect(cancelada.estaCancelada, isTrue);
    expect(cancelada.sePuedeCambiar, isFalse);
    expect(cancelada.eventos.single.tipo, TipoDeEvento.cancelacion);

    final delDia = await conexiones.ventas.obtenerVentasDelDia(hoy());
    expect(delDia.ventas.length, 1);
    expect(delDia.cuantas, 0);
    expect(delDia.canceladas, 1);
    expect(delDia.total, Dinero.cero);

    await esperarError(
      conexiones.ventas.cancelarVenta(venta.id),
      'venta_cancelada',
    );
  });

  test('al editar una venta se recalcula el total y queda quién fue', () async {
    final conexiones = await entrarComoDuena();
    final venta = await conexiones.ventas.registrarVenta(
      lineas: unFlan,
      metodoDePago: MetodoDePago.efectivo,
      montoRecibido: const Dinero.pesos(50),
    );

    final editada = await conexiones.ventas.editarVenta(
      venta.id,
      lineas: const [LineaPorCobrar(productoId: '3', cantidad: 2)],
      nota: 'Eran dos',
    );

    expect(editada.total, const Dinero.pesos(70));
    // Los $50 que pagó ya no alcanzan: queda como pago exacto.
    expect(editada.montoRecibido, const Dinero.pesos(70));
    expect(editada.fueEditada, isTrue);
    expect(editada.eventos.single.perfilId, '1');
    expect(editada.sePuedeCambiar, isTrue);
  });

  test(
    'la caja espera: fondo + efectivo − gastos pagados de la caja',
    () async {
      final conexiones = await entrarComoDuena();
      await conexiones.ventas.registrarVenta(
        lineas: unFlan,
        metodoDePago: MetodoDePago.efectivo,
      );
      await conexiones.ventas.registrarVenta(
        lineas: unFlan,
        metodoDePago: MetodoDePago.tarjeta,
      );

      // El ejemplo abre con $500 y trae $420 pagados de la caja y $250
      // aparte.
      final caja = (await conexiones.caja.obtenerCajaAbierta())!;
      expect(caja.ventasEnEfectivo, const Dinero.pesos(35));
      expect(caja.ventasConTarjeta, const Dinero.pesos(35));
      expect(caja.gastosDeCaja, const Dinero.pesos(420));
      expect(caja.gastosTotales, const Dinero.pesos(670));
      expect(caja.efectivoEsperado, const Dinero.pesos(115));

      final cierre = await conexiones.caja.cerrarCaja(
        contado: const Dinero.pesos(120),
        nota: 'di cambio de menos',
      );
      expect(cierre.diferencia, const Dinero.pesos(5));
      expect(await conexiones.caja.obtenerCajaAbierta(), isNull);

      // Cerrar es definitivo: lo de ese día ya no se puede cambiar.
      final ventas = await conexiones.ventas.obtenerVentasDelDia(hoy());
      await esperarError(
        conexiones.ventas.cancelarVenta(ventas.ventas.first.id),
        'caja_cerrada',
      );
      final gastos = await conexiones.gastos.obtenerGastos(
        desde: hoy(),
        hasta: hoy(),
      );
      final deCaja = gastos.gastos.firstWhere((gasto) => gasto.deCaja);
      expect(deCaja.editable, isFalse);
      await esperarError(
        conexiones.gastos.eliminarGasto(deCaja.id),
        'caja_cerrada',
      );

      final cierres = await conexiones.caja.obtenerCierres();
      expect(cierres.cierres.single.vendido, const Dinero.pesos(70));
    },
  );

  test(
    'el resumen cuenta vendido − gastos, sin las ventas canceladas',
    () async {
      final conexiones = await entrarComoDuena();
      await conexiones.ventas.registrarVenta(
        lineas: const [
          LineaPorCobrar(productoId: '3', cantidad: 3),
          LineaPorCobrar(productoId: '10', presentacionId: '102', cantidad: 5),
        ],
        metodoDePago: MetodoDePago.efectivo,
      );
      final cancelada = await conexiones.ventas.registrarVenta(
        lineas: unFlan,
        metodoDePago: MetodoDePago.efectivo,
      );
      await conexiones.ventas.cancelarVenta(cancelada.id);

      final resumen = await conexiones.resumen.obtenerResumen(
        periodo: Periodo.semana,
        fecha: hoy(),
        secciones: SeccionDeResumen.values.toSet(),
        orden: OrdenDeProductos.cantidad,
      );

      // 3 flanes ($105) + 5 horchatas grandes ($125).
      expect(resumen.totales.vendido, const Dinero.pesos(230));
      expect(resumen.totales.numeroDeVentas, 1);
      expect(resumen.totales.gastos, const Dinero.pesos(670));
      expect(resumen.totales.utilidad, const Dinero.pesos(-440));
      expect(resumen.porDia.length, 7);
      expect(resumen.desde, lunesDe(hoy()));

      // Por piezas gana la horchata; cada tamaño cuenta aparte.
      expect(resumen.masVendidos.first.nombreCompleto, 'Horchata grande');
      expect(resumen.masVendidos.first.piezas, 5);
      expect(resumen.gastosPorCategoria.map((gasto) => gasto.nombre), [
        'Ingredientes',
        'Plaza',
      ]);
    },
  );

  test('una cuenta nueva empieza sin dueña y sin nada', () async {
    final conexiones = Conexiones.simuladas();

    final cuenta = await conexiones.sesion.crearCuenta(
      nombreDelNegocio: 'Tacos Chela',
      correo: 'chela@ejemplo.com',
      contrasena: 'salsa-verde',
    );
    expect(cuenta.tieneDueno, isFalse);

    final conDuena = await conexiones.sesion.crearDuena(
      nombre: 'Chela',
      pin: '4321',
    );
    expect(conDuena.perfilActivo?.esDueno, isTrue);
    expect((await conexiones.catalogo.obtenerCatalogo()).productos, isEmpty);
    expect(await conexiones.caja.obtenerCajaAbierta(), isNull);

    await esperarError(
      conexiones.sesion.crearDuena(nombre: 'Otra', pin: '1111'),
      'ya_hay_dueno',
    );
  });
}
