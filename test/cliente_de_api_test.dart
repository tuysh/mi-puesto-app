import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mi_puesto/controladores/controlador_de_catalogo.dart';
import 'package:mi_puesto/controladores/sesion.dart';
import 'package:mi_puesto/datos/conexiones.dart';
import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/http/almacen_de_sesion_en_memoria.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/estado_de_acceso.dart';
import 'package:mi_puesto/datos/modelos/foto_nueva.dart';
import 'package:mi_puesto/datos/modelos/presentacion.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/modelos/resumen.dart';
import 'package:mi_puesto/datos/modelos/venta.dart';

/// Prueba la conexión con el servidor (API v2) sin usar la red: un
/// servidor de mentira contesta lo que cada prueba le indica.
void main() {
  http.Response json(Object cuerpo, [int codigo = 200]) {
    return http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      codigo,
      headers: {'content-type': 'application/json'},
    );
  }

  /// Conexiones con un token ya guardado (`abc`) que responden lo que diga
  /// [responder].
  Conexiones conectar(
    Future<http.Response> Function(http.Request peticion) responder, {
    AlmacenDeSesionEnMemoria? almacen,
  }) {
    return Conexiones.http(
      urlDelServidor: 'https://servidor.prueba',
      almacen: almacen ?? AlmacenDeSesionEnMemoria('abc'),
      cliente: MockClient(responder),
    );
  }

  /// Lo que responden el login, `/cuenta` y las rutas del PIN.
  Map<String, Object?> cuenta({Object? perfil}) {
    return {
      'negocio': {
        'id': 1,
        'nombre': 'Puesto Doña Mari',
        'email': 'mari@ejemplo.com',
      },
      'perfil': perfil,
      'perfiles': [
        {'id': 1, 'nombre': 'Mari', 'rol': 'dueno', 'color': 0},
        {'id': 2, 'nombre': 'Lupe', 'rol': 'vendedor', 'color': 1},
      ],
    };
  }

  /// Un producto como lo manda el servidor.
  Map<String, Object?> producto({String imagenUrl = ''}) {
    return {
      'id': 10,
      'nombre': 'Horchata',
      'categoria_id': 3,
      'precio': null,
      'representacion': imagenUrl.isEmpty ? 'emoji' : 'imagen',
      'letras': 'Ho',
      'emoji': '🥛',
      'disponible': true,
      'imagen_url': imagenUrl,
      'presentaciones': [
        {'id': 1, 'nombre': 'Chica', 'precio': '15.00'},
        {'id': 2, 'nombre': 'Grande', 'precio': '25.00'},
      ],
    };
  }

  group('dinero', () {
    test('se lee sin perder centavos', () {
      expect(dineroDeJson('45.00'), const Dinero.pesos(45));
      expect(dineroDeJson('0.10'), const Dinero.centavos(10));
      expect(dineroDeJson('1234.5'), const Dinero.centavos(123450));
      expect(dineroDeJson('-35.05'), const Dinero.centavos(-3505));
      expect(dineroDeJson(null), Dinero.cero);
      expect(dineroONadaDeJson(null), isNull);
    });

    test('se escribe con dos decimales', () {
      expect(dineroAJson(const Dinero.pesos(45)), '45.00');
      expect(dineroAJson(const Dinero.centavos(5)), '0.05');
      expect(dineroAJson(const Dinero.centavos(-3505)), '-35.05');
    });
  });

  test('iniciar sesión guarda el token y lo manda en lo que sigue', () async {
    final almacen = AlmacenDeSesionEnMemoria();
    final peticiones = <http.Request>[];
    final conexiones = conectar(almacen: almacen, (peticion) async {
      peticiones.add(peticion);
      if (peticion.url.path == '/api/v2/cuenta/login') {
        return json({'token': 'tok-1', ...cuenta()});
      }
      return json(
        cuenta(perfil: {'id': 2, 'nombre': 'Lupe', 'rol': 'vendedor'}),
      );
    });

    final alEntrar = await conexiones.sesion.iniciarSesion(
      correo: 'mari@ejemplo.com',
      contrasena: 'pay-de-limon',
    );
    expect(alEntrar!.negocio.nombre, 'Puesto Doña Mari');
    expect(alEntrar.perfilActivo, isNull);
    expect(alEntrar.perfiles.first.esDueno, isTrue);
    expect(await almacen.leerToken(), 'tok-1');
    expect(peticiones.single.headers.containsKey('Authorization'), isFalse);
    expect(jsonDecode(peticiones.single.body), {
      'email': 'mari@ejemplo.com',
      'password': 'pay-de-limon',
    });

    // El PIN viaja como texto, para no perder los ceros de adelante.
    final conLupe = await conexiones.sesion.entrarComoPerfil(
      perfilId: '2',
      pin: '0123',
    );
    expect(conLupe!.perfilActivo!.nombre, 'Lupe');
    final entrar = peticiones.last;
    expect(entrar.url.path, '/api/v2/perfiles/2/entrar');
    expect(entrar.headers['Authorization'], 'Bearer tok-1');
    expect(entrar.headers['Content-Type'], startsWith('application/json'));
    expect(jsonDecode(entrar.body), {'pin': '0123'});
  });

  test('la cuenta dice en qué paso va el dispositivo', () async {
    Object? respuesta = cuenta();
    final conexiones = conectar((peticion) async => json(respuesta!));
    final sesion = Sesion(conexiones.sesion);

    expect(await sesion.consultarAcceso(), EstadoDeAcceso.faltaElegirPersona);

    respuesta = cuenta(perfil: {'id': 1, 'nombre': 'Mari', 'rol': 'dueno'});
    expect(await sesion.consultarAcceso(), EstadoDeAcceso.dentro);
    expect(sesion.esDuena, isTrue);

    // El registro quedó a medias: hay cuenta, pero todavía no hay dueña.
    respuesta = {...cuenta(), 'perfiles': <Object>[]};
    expect(await sesion.consultarAcceso(), EstadoDeAcceso.faltaLaDuena);
  });

  test('una contraseña incorrecta no es un error: se devuelve null', () async {
    var respuesta = json({
      'detail': 'Correo o contraseña incorrectos.',
      'codigo': 'credenciales',
    }, 401);
    final conexiones = conectar(
      almacen: AlmacenDeSesionEnMemoria(),
      (peticion) async => respuesta,
    );

    final sinEntrar = await conexiones.sesion.iniciarSesion(
      correo: 'mari@ejemplo.com',
      contrasena: 'otra',
    );
    expect(sinEntrar, isNull);
  });

  test('el PIN: 403 es incorrecto y 429 es bloqueado', () async {
    var respuesta = json({
      'detail': 'PIN incorrecto.',
      'codigo': 'pin_incorrecto',
    }, 403);
    final conexiones = conectar((peticion) async => respuesta);

    final sinEntrar = await conexiones.sesion.entrarComoPerfil(
      perfilId: '2',
      pin: '9999',
    );
    expect(sinEntrar, isNull);

    respuesta = json({'detail': 'Demasiados intentos.'}, 429);
    await expectLater(
      conexiones.sesion.entrarComoPerfil(perfilId: '2', pin: '9999'),
      throwsA(
        isA<ErrorDelServidor>()
            .having((e) => e.codigoHttp, 'codigoHttp', 429)
            .having((e) => e.mensaje, 'mensaje', contains('5 minutos')),
      ),
    );
  });

  test('de un error se muestra `detail` y se conserva su `codigo`', () async {
    final conexiones = conectar(
      (peticion) async => json({
        'detail': 'La caja está cerrada. Ábrela para poder registrar.',
        'codigo': 'sin_caja',
      }, 409),
    );

    await expectLater(
      conexiones.ventas.registrarVenta(
        lineas: const [LineaPorCobrar(productoId: '6', cantidad: 1)],
        metodoDePago: MetodoDePago.efectivo,
      ),
      throwsA(
        isA<ErrorDelServidor>()
            .having((e) => e.codigo, 'codigo', CodigosDeError.sinCaja)
            .having(
              (e) => e.mensaje,
              'mensaje',
              'La caja está cerrada. Ábrela para poder registrar.',
            ),
      ),
    );
  });

  test('los errores por campo se juntan en un solo mensaje', () async {
    final conexiones = conectar(
      almacen: AlmacenDeSesionEnMemoria(),
      (peticion) async => json({
        'password': [
          'Esta contraseña es muy común.',
          'Esta contraseña es totalmente numérica.',
        ],
      }, 400),
    );

    await expectLater(
      conexiones.sesion.crearCuenta(
        nombreDelNegocio: 'Puesto',
        correo: 'a@b.mx',
        contrasena: '12345678',
      ),
      throwsA(
        isA<ErrorDelServidor>().having(
          (e) => e.mensaje,
          'mensaje',
          'Esta contraseña es muy común. '
              'Esta contraseña es totalmente numérica.',
        ),
      ),
    );
  });

  test('un 401 borra el token y avisa para volver a iniciar', () async {
    final almacen = AlmacenDeSesionEnMemoria('abc');
    final conexiones = conectar(
      almacen: almacen,
      (peticion) async => json({'detail': 'Token inválido.'}, 401),
    );
    var avisos = 0;
    conexiones.sesion.avisarSiSePierdeLaSesion(() => avisos++);

    await expectLater(
      conexiones.catalogo.obtenerCatalogo(),
      throwsA(isA<ErrorDelServidor>()),
    );
    expect(avisos, 1);
    expect(await almacen.leerToken(), isNull);

    // Al abrir la aplicación con un token vencido no se avisa: la pantalla
    // de arranque ya manda a "Inicia sesión".
    await almacen.guardarToken('abc');
    final otras = conectar(
      almacen: almacen,
      (peticion) async => json({'detail': 'x'}, 401),
    );
    otras.sesion.avisarSiSePierdeLaSesion(() => avisos++);
    expect(await otras.sesion.consultarCuenta(), isNull);
    expect(avisos, 1);
  });

  test('"sin_perfil" avisa para volver a "¿Quién vende hoy?"', () async {
    final conexiones = conectar(
      (peticion) async => json({
        'detail': 'Escribe tu PIN para continuar.',
        'codigo': 'sin_perfil',
      }, 403),
    );
    var avisos = 0;
    conexiones.sesion.avisarSiNoHayNadieDentro(() => avisos++);

    await expectLater(
      conexiones.catalogo.obtenerCatalogo(),
      throwsA(isA<ErrorDelServidor>()),
    );
    expect(avisos, 1);
  });

  test('sin red, el error es de conexión', () async {
    final conexiones = conectar(
      (peticion) async => throw const SocketException('sin señal'),
    );

    await expectLater(
      conexiones.caja.obtenerCajaAbierta(),
      throwsA(isA<ErrorDeConexion>()),
    );
  });

  test('el catálogo trae productos con un precio o con tamaños', () async {
    final conexiones = conectar((peticion) async {
      expect(peticion.url.path, '/api/v2/catalogo');
      return json({
        'categorias': [
          {'id': 3, 'nombre': 'Bebidas', 'color': 2, 'orden': 0},
        ],
        'productos': [
          producto(),
          {
            'id': 1,
            'nombre': 'Pay limón',
            'categoria_id': null,
            'precio': '45.00',
            'representacion': 'letras',
            'letras': 'Pa',
            'emoji': '',
            'disponible': false,
            'imagen_url': '',
            'presentaciones': <Object>[],
          },
        ],
      });
    });

    final catalogo = await conexiones.catalogo.obtenerCatalogo();
    final horchata = catalogo.productos[0];
    final pay = catalogo.productos[1];

    expect(catalogo.categorias.single.color, 2);
    expect(horchata.precio, isNull);
    expect(horchata.tieneTamanos, isTrue);
    expect(horchata.precioDesde, const Dinero.pesos(15));
    expect(horchata.representacion, Representacion.emoji);
    expect(pay.precio, const Dinero.pesos(45));
    expect(pay.categoriaId, isNull);
    expect(pay.disponible, isFalse);
  });

  test('al guardar se manda un precio o los tamaños, nunca los dos', () async {
    final cuerpos = <Map<String, dynamic>>[];
    final conexiones = conectar((peticion) async {
      cuerpos.add(jsonDecode(peticion.body) as Map<String, dynamic>);
      return json(producto());
    });

    await conexiones.catalogo.guardarProducto(
      const Producto(
        id: '10',
        nombre: 'Horchata',
        categoriaId: '3',
        precio: null,
        representacion: Representacion.emoji,
        emoji: '🥛',
        presentaciones: [
          // El que ya existía lleva su `id`; el nuevo, no.
          Presentacion(id: '1', nombre: 'Chica', precio: Dinero.pesos(15)),
          Presentacion(id: '', nombre: 'Jarra', precio: Dinero.pesos(60)),
        ],
      ),
    );
    expect(cuerpos.single.containsKey('precio'), isFalse);
    expect(cuerpos.single['representacion'], 'emoji');
    expect(cuerpos.single['presentaciones'], [
      {'id': 1, 'nombre': 'Chica', 'precio': '15.00'},
      {'nombre': 'Jarra', 'precio': '60.00'},
    ]);

    // Un producto nuevo, sin categoría, a un solo precio y con foto: la
    // representación "imagen" no se manda (la pone el servidor al subirla).
    await conexiones.catalogo.guardarProducto(
      const Producto(
        id: '',
        nombre: 'Tostilocos',
        categoriaId: null,
        precio: Dinero.pesos(45),
        representacion: Representacion.imagen,
      ),
    );
    expect(cuerpos.last['precio'], '45.00');
    expect(cuerpos.last['categoria_id'], isNull);
    expect(cuerpos.last.containsKey('presentaciones'), isFalse);
    expect(cuerpos.last.containsKey('representacion'), isFalse);
  });

  test('la foto se sube aparte, como archivo y con el token', () async {
    final peticiones = <http.Request>[];
    final conexiones = conectar((peticion) async {
      peticiones.add(peticion);
      // En desarrollo la dirección llega sin el inicio.
      return json(
        producto(imagenUrl: peticion.method == 'PUT' ? '/media/a.webp' : ''),
      );
    });

    final conFoto = await conexiones.catalogo.subirFotoDeProducto(
      '10',
      FotoNueva(
        bytes: Uint8List.fromList([1, 2, 3]),
        nombreDeArchivo: 'horchata.jpg',
      ),
    );
    final subida = peticiones.single;
    expect(subida.method, 'PUT');
    expect(subida.url.path, '/api/v2/productos/10/foto');
    expect(subida.headers['Authorization'], 'Bearer abc');
    expect(subida.headers['content-type'], startsWith('multipart/form-data'));
    expect(subida.body, contains('name="foto"; filename="horchata.jpg"'));
    expect(conFoto.representacion, Representacion.imagen);
    expect(conFoto.imagenUrl, 'https://servidor.prueba/media/a.webp');

    final sinFoto = await conexiones.catalogo.quitarFotoDeProducto('10');
    expect(peticiones.last.method, 'DELETE');
    expect(sinFoto.imagenUrl, isEmpty);
  });

  test(
    'al guardar con foto nueva vale la dirección que responde el PUT',
    () async {
      final metodos = <String>[];
      final conexiones = conectar((peticion) async {
        metodos.add(peticion.method);
        return switch (peticion.method) {
          // El catálogo y el PATCH todavía traen la foto de antes…
          'GET' => json({
            'categorias': <Object>[],
            'productos': [producto(imagenUrl: 'https://fotos.prueba/v.webp')],
          }),
          'PATCH' => json(producto(imagenUrl: 'https://fotos.prueba/v.webp')),
          // …y el PUT estrena dirección; la vieja deja de existir.
          _ => json(producto(imagenUrl: 'https://fotos.prueba/n.webp')),
        };
      });
      final catalogo = ControladorDeCatalogo(conexiones.catalogo);
      await catalogo.cargar();
      final antes = catalogo.productos.single;
      expect(antes.imagenUrl, 'https://fotos.prueba/v.webp');

      final guardado = await catalogo.guardarProducto(
        antes,
        fotoNueva: FotoNueva(
          bytes: Uint8List.fromList([1, 2, 3]),
          nombreDeArchivo: 'horchata.jpg',
        ),
      );

      expect(metodos, ['GET', 'PATCH', 'PUT']);
      expect(guardado.imagenUrl, 'https://fotos.prueba/n.webp');
      expect(
        catalogo.productos.single.imagenUrl,
        'https://fotos.prueba/n.webp',
      );
    },
  );

  test('una venta sin respuesta se reintenta con el mismo uuid', () async {
    final cuerpos = <Map<String, dynamic>>[];
    var hayRed = false;
    final conexiones = conectar((peticion) async {
      cuerpos.add(jsonDecode(peticion.body) as Map<String, dynamic>);
      if (!hayRed) throw const SocketException('sin señal');
      return json({
        'id': 4,
        'uuid': cuerpos.last['uuid'],
        'creada_en': '2026-11-11T00:02:38.352483Z',
        'perfil_id': 1,
        'caja_id': 1,
        'metodo_pago': 'efectivo',
        'total': '110.00',
        'monto_recibido': '200.00',
        'cambio': '90.00',
        'nota': 'Sin hielo',
        'editada_en': null,
        'cancelada_en': null,
        'cancelada_por_id': null,
        'lineas': [
          {
            'producto_id': 6,
            'presentacion_id': null,
            'nombre_producto': 'Esquite',
            'nombre_presentacion': '',
            'cantidad': 1,
            'precio_unitario': '35.00',
            'subtotal': '35.00',
          },
          {
            'producto_id': 10,
            'presentacion_id': 2,
            'nombre_producto': 'Horchata',
            'nombre_presentacion': 'Grande',
            'cantidad': 3,
            'precio_unitario': '25.00',
            'subtotal': '75.00',
          },
        ],
      }, 201);
    });

    Future<Venta> vender({Dinero? montoRecibido}) {
      return conexiones.ventas.registrarVenta(
        lineas: const [
          LineaPorCobrar(productoId: '6', cantidad: 1),
          LineaPorCobrar(productoId: '10', presentacionId: '2', cantidad: 3),
        ],
        metodoDePago: MetodoDePago.efectivo,
        montoRecibido: montoRecibido,
        nota: 'Sin hielo',
      );
    }

    await expectLater(
      vender(montoRecibido: const Dinero.pesos(200)),
      throwsA(isA<ErrorDeConexion>()),
    );
    hayRed = true;
    final venta = await vender(montoRecibido: const Dinero.pesos(200));
    expect(venta.total, const Dinero.pesos(110));
    expect(venta.cambio, const Dinero.pesos(90));
    expect(venta.lineas.last.nombreCompleto, 'Horchata grande');
    expect(cuerpos[1], {
      'uuid': cuerpos[0]['uuid'],
      'metodo_pago': 'efectivo',
      'lineas': [
        {'producto_id': 6, 'cantidad': 1},
        // `presentacion_id` solo va si el producto tiene tamaños.
        {'producto_id': 10, 'presentacion_id': 2, 'cantidad': 3},
      ],
      'monto_recibido': '200.00',
      'nota': 'Sin hielo',
    });

    // Un pedido distinto lleva otro uuid, y el pago exacto no manda
    // `monto_recibido`.
    await vender();
    expect(cuerpos[2]['uuid'], isNot(cuerpos[0]['uuid']));
    expect(cuerpos[2].containsKey('monto_recibido'), isFalse);
    expect(
      cuerpos[2]['uuid'],
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });

  test(
    'la caja: null si está cerrada, y solo lo básico para quien vende',
    () async {
      Object respuesta = {'caja': null};
      final conexiones = conectar((peticion) async => json(respuesta));

      expect(await conexiones.caja.obtenerCajaAbierta(), isNull);

      // Quien solo vende no recibe los montos.
      respuesta = {
        'caja': {
          'id': 1,
          'fecha': '2026-11-10',
          'abierta_en': '2026-11-11T00:02:35.574411Z',
          'abierta': true,
        },
      };
      final caja = await conexiones.caja.obtenerCajaAbierta();
      expect(caja!.fecha, DateTime(2026, 11, 10));
      expect(caja.efectivoEsperado, Dinero.cero);
      expect(caja.esDeUnDiaAnteriorA(DateTime(2026, 11, 11, 9)), isTrue);
      expect(caja.esDeUnDiaAnteriorA(DateTime(2026, 11, 10, 23)), isFalse);
    },
  );

  test('el resumen pide solo las secciones que se le indican', () async {
    late Uri direccion;
    final conexiones = conectar((peticion) async {
      direccion = peticion.url;
      return json({
        'periodo': 'semana',
        'desde': '2026-11-09',
        'hasta': '2026-11-15',
        'totales': {
          'vendido': '365.00',
          'ventas': 4,
          'efectivo': '275.00',
          'tarjeta': '90.00',
          'gastos': '850.00',
          'utilidad': '-485.00',
        },
        'gastos_por_categoria': [
          {
            'categoria_id': null,
            'nombre': null,
            'color': null,
            'total': '430.00',
          },
        ],
      });
    });

    final resumen = await conexiones.resumen.obtenerResumen(
      periodo: Periodo.semana,
      fecha: DateTime(2026, 11, 10),
      secciones: {
        SeccionDeResumen.totales,
        SeccionDeResumen.gastosPorCategoria,
      },
      orden: OrdenDeProductos.monto,
    );

    expect(direccion.path, '/api/v2/resumen');
    expect(direccion.queryParameters, {
      'periodo': 'semana',
      'fecha': '2026-11-10',
      'secciones': 'totales,gastos_por_categoria',
      'orden': 'monto',
      'top': '5',
    });
    expect(resumen.totales.utilidad, const Dinero.pesos(-485));
    // Lo que no se pidió llega vacío; los gastos sin categoría, sin nombre.
    expect(resumen.porDia, isEmpty);
    expect(resumen.masVendidos, isEmpty);
    expect(resumen.gastosPorCategoria.single.nombre, isNull);
  });
}
