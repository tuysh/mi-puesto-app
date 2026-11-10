import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mi_puesto/controladores/controlador_de_catalogo.dart';
import 'package:mi_puesto/datos/conexiones.dart';
import 'package:mi_puesto/datos/error_del_servidor.dart';
import 'package:mi_puesto/datos/http/almacen_de_sesion.dart';
import 'package:mi_puesto/datos/http/almacen_de_sesion_en_memoria.dart';
import 'package:mi_puesto/datos/http/conversion_de_json.dart';
import 'package:mi_puesto/datos/modelos/dinero.dart';
import 'package:mi_puesto/datos/modelos/estado_de_acceso.dart';
import 'package:mi_puesto/datos/modelos/foto_nueva.dart';
import 'package:mi_puesto/datos/modelos/linea_de_pedido.dart';
import 'package:mi_puesto/datos/modelos/producto.dart';
import 'package:mi_puesto/datos/modelos/vendedor.dart';
import 'package:mi_puesto/nucleo/tema/colores.dart';

/// Prueba la conexión con el servidor sin usar la red: un servidor de
/// mentira contesta lo que cada prueba le indica.
void main() {
  const sesionGuardada = SesionGuardada(token: 'abc', puestoId: '7');
  const vendedor = Vendedor(id: '1', nombre: 'Mari', colores: Pasteles.rosa);
  const pay = Producto(
    id: '2',
    nombre: 'Pay de limón',
    nombreCorto: 'Pay limón',
    emoji: '🥧',
    precio: Dinero.pesos(45),
    costo: Dinero.pesos(18),
    categoriaId: '1',
  );

  http.Response json(Object cuerpo, [int codigo = 200]) {
    return http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      codigo,
      headers: {'content-type': 'application/json'},
    );
  }

  group('dinero', () {
    test('se lee sin perder centavos', () {
      expect(dineroDeJson('45.00'), const Dinero.pesos(45));
      expect(dineroDeJson('0.10'), const Dinero.centavos(10));
      expect(dineroDeJson('1234.5'), const Dinero.centavos(123450));
      expect(dineroDeJson('-35.05'), const Dinero.centavos(-3505));
      expect(dineroDeJson(null), Dinero.cero);
    });

    test('se escribe con dos decimales', () {
      expect(dineroAJson(const Dinero.pesos(45)), '45.00');
      expect(dineroAJson(const Dinero.centavos(5)), '0.05');
      expect(dineroAJson(const Dinero.centavos(-3505)), '-35.05');
    });
  });

  test('los colores van y vienen como #RRGGBB', () {
    expect(colorAJson(Pasteles.rosa.fondo), '#F9D3DE');
    expect(
      identical(coloresDeJson('#F9D3DE', '#8A2149'), Pasteles.rosa),
      isTrue,
    );
    expect(coloresDeJson('#102030', '#FFFFFF').fondo.toARGB32(), 0xFF102030);
  });

  test('iniciar sesión guarda el token y lo manda en lo que sigue', () async {
    final almacen = AlmacenDeSesionEnMemoria();
    final peticiones = <http.Request>[];
    final conexiones = Conexiones.http(
      urlDelServidor: 'https://servidor.prueba',
      almacen: almacen,
      cliente: MockClient((peticion) async {
        peticiones.add(peticion);
        if (peticion.url.path == '/api/v1/cuenta/login') {
          return json({
            'token': 'tok-1',
            'puestos': [
              {'id': 7, 'nombre': 'Puesto Doña Mari', 'tiene_pin': true},
            ],
          });
        }
        return http.Response('', 204);
      }),
    );

    final entro = await conexiones.sesion.iniciarSesion(
      correo: 'mari@ejemplo.com',
      contrasena: 'pay-de-limon',
    );
    expect(entro, isTrue);
    expect((await almacen.leer())!.token, 'tok-1');
    expect(peticiones.single.headers.containsKey('Authorization'), isFalse);
    expect(jsonDecode(peticiones.single.body), {
      'email': 'mari@ejemplo.com',
      'password': 'pay-de-limon',
    });

    expect(await conexiones.sesion.validarPin('0123'), isTrue);
    final verificar = peticiones.last;
    expect(verificar.url.path, '/api/v1/puestos/7/pin/verificar');
    expect(verificar.headers['Authorization'], 'Bearer tok-1');
    expect(verificar.headers['Content-Type'], startsWith('application/json'));
    expect(jsonDecode(verificar.body), {'pin': '0123'});
  });

  test('el PIN: 403 es incorrecto y 429 es bloqueado', () async {
    var codigo = 403;
    final conexiones = Conexiones.http(
      urlDelServidor: 'https://servidor.prueba',
      almacen: AlmacenDeSesionEnMemoria(sesionGuardada),
      cliente: MockClient(
        (peticion) async => json({'detail': 'PIN incorrecto.'}, codigo),
      ),
    );

    expect(await conexiones.sesion.validarPin('9999'), isFalse);
    codigo = 429;
    await expectLater(
      conexiones.sesion.validarPin('9999'),
      throwsA(isA<ErrorDelServidor>().having((e) => e.codigo, 'codigo', 429)),
    );
  });

  test('los errores por campo se juntan en un solo mensaje', () async {
    final conexiones = Conexiones.http(
      urlDelServidor: 'https://servidor.prueba',
      almacen: AlmacenDeSesionEnMemoria(),
      cliente: MockClient(
        (peticion) async => json({
          'password': [
            'Esta contraseña es muy común.',
            'Esta contraseña es totalmente numérica.',
          ],
        }, 400),
      ),
    );

    await expectLater(
      conexiones.sesion.crearCuenta(correo: 'a@b.mx', contrasena: '12345678'),
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

  test('un 401 borra la sesión y avisa para volver a iniciar', () async {
    final almacen = AlmacenDeSesionEnMemoria(sesionGuardada);
    final conexiones = Conexiones.http(
      urlDelServidor: 'https://servidor.prueba',
      almacen: almacen,
      cliente: MockClient(
        (peticion) async => json({'detail': 'Token inválido.'}, 401),
      ),
    );
    var avisos = 0;
    conexiones.sesion.avisarSiSePierdeLaSesion(() => avisos++);

    await expectLater(
      conexiones.vendedores.obtenerVendedores(),
      throwsA(isA<ErrorDelServidor>()),
    );
    expect(avisos, 1);
    expect(await almacen.leer(), isNull);

    // Al abrir la aplicación con un token vencido no se avisa: la pantalla
    // de arranque ya manda a "Inicia sesión".
    await almacen.guardar(sesionGuardada);
    final otras = Conexiones.http(
      urlDelServidor: 'https://servidor.prueba',
      almacen: almacen,
      cliente: MockClient((peticion) async => json({'detail': 'x'}, 401)),
    );
    otras.sesion.avisarSiSePierdeLaSesion(() => avisos++);
    expect(await otras.sesion.consultarAcceso(), EstadoDeAcceso.sinSesion);
    expect(avisos, 1);
  });

  test('la foto se sube aparte, como archivo y con el token', () async {
    final peticiones = <http.Request>[];
    final conexiones = Conexiones.http(
      urlDelServidor: 'https://servidor.prueba',
      almacen: AlmacenDeSesionEnMemoria(sesionGuardada),
      cliente: MockClient((peticion) async {
        peticiones.add(peticion);
        return json({
          'id': 2,
          'nombre': 'Pay de limón',
          'nombre_corto': 'Pay limón',
          'emoji': '',
          'letras': 'PL',
          // En desarrollo la dirección llega sin el inicio.
          'foto_url': peticion.method == 'PUT' ? '/media/puestos/7/a.webp' : '',
          'precio': '45.00',
          'costo': '18.00',
          'a_la_venta': true,
          'categoria_id': 1,
        });
      }),
    );

    final conFoto = await conexiones.catalogo.subirFotoDeProducto(
      '2',
      FotoNueva(
        bytes: Uint8List.fromList([1, 2, 3]),
        nombreDeArchivo: 'pay.jpg',
      ),
    );
    final subida = peticiones.single;
    expect(subida.method, 'PUT');
    expect(subida.url.path, '/api/v1/puestos/7/productos/2/foto');
    expect(subida.headers['Authorization'], 'Bearer abc');
    expect(subida.headers['content-type'], startsWith('multipart/form-data'));
    expect(subida.body, contains('name="foto"; filename="pay.jpg"'));
    expect(conFoto.fotoUrl, 'https://servidor.prueba/media/puestos/7/a.webp');
    expect(conFoto.letras, 'PL');

    final sinFoto = await conexiones.catalogo.quitarFotoDeProducto('2');
    expect(peticiones.last.method, 'DELETE');
    expect(sinFoto.fotoUrl, isEmpty);

    // Las letras viajan con el producto; la foto no.
    await conexiones.catalogo.guardarProducto(
      pay.copiarCon(emoji: '', letras: 'PL', fotoUrl: 'https://x/y.webp'),
    );
    final cuerpo = jsonDecode(peticiones.last.body) as Map<String, dynamic>;
    expect(cuerpo['letras'], 'PL');
    expect(cuerpo['emoji'], '');
    expect(cuerpo.containsKey('foto_url'), isFalse);
  });

  test(
    'al guardar con foto nueva vale la dirección que responde el PUT',
    () async {
      Map<String, Object> producto(String fotoUrl) => {
        'id': 2,
        'nombre': 'Pay de limón',
        'nombre_corto': 'Pay limón',
        'emoji': '🥧',
        'letras': '',
        'foto_url': fotoUrl,
        'precio': '45.00',
        'costo': '18.00',
        'a_la_venta': true,
        'categoria_id': 1,
      };
      final metodos = <String>[];
      final conexiones = Conexiones.http(
        urlDelServidor: 'https://servidor.prueba',
        almacen: AlmacenDeSesionEnMemoria(sesionGuardada),
        cliente: MockClient((peticion) async {
          metodos.add(peticion.method);
          if (peticion.url.path.endsWith('/categorias')) return json([]);
          return switch (peticion.method) {
            // La lista y el PATCH todavía traen la foto de antes…
            'GET' => json([producto('https://fotos.prueba/vieja.webp')]),
            'PATCH' => json(producto('https://fotos.prueba/vieja.webp')),
            // …y el PUT estrena dirección; la vieja deja de existir.
            _ => json(producto('https://fotos.prueba/nueva.webp')),
          };
        }),
      );
      final catalogo = ControladorDeCatalogo(conexiones.catalogo);
      await catalogo.cargar();
      final antes = catalogo.productos.single;
      expect(antes.fotoUrl, 'https://fotos.prueba/vieja.webp');

      final guardado = await catalogo.guardarProducto(
        antes.copiarCon(fotoUrl: ''),
        fotoNueva: FotoNueva(
          bytes: Uint8List.fromList([1, 2, 3]),
          nombreDeArchivo: 'pay.jpg',
        ),
      );

      expect(metodos, ['GET', 'GET', 'PATCH', 'PUT']);
      expect(guardado.fotoUrl, 'https://fotos.prueba/nueva.webp');
      expect(
        catalogo.productos.single.fotoUrl,
        'https://fotos.prueba/nueva.webp',
      );
    },
  );

  test('una venta sin respuesta se reintenta con el mismo uuid', () async {
    final cuerpos = <Map<String, dynamic>>[];
    var hayRed = false;
    final conexiones = Conexiones.http(
      urlDelServidor: 'https://servidor.prueba',
      almacen: AlmacenDeSesionEnMemoria(sesionGuardada),
      cliente: MockClient((peticion) async {
        cuerpos.add(jsonDecode(peticion.body) as Map<String, dynamic>);
        if (!hayRed) throw const SocketException('sin señal');
        return json({
          'id': 4,
          'creada_en': '2026-11-09T23:57:56.976779Z',
          'total': '90.00',
          'pago_con': cuerpos.last['pago_con'] == null ? null : '100.00',
        }, 201);
      }),
    );

    Future<Object> vender(int piezas, Dinero pagoCon) {
      return conexiones.ventas.registrarVenta(
        lineas: [LineaDePedido(producto: pay, cantidad: piezas)],
        pagoCon: pagoCon,
        vendedor: vendedor,
      );
    }

    await expectLater(
      vender(2, const Dinero.pesos(100)),
      throwsA(isA<ErrorDelServidor>()),
    );
    hayRed = true;
    final venta = await vender(2, const Dinero.pesos(100));
    expect(venta, isNotNull);
    expect(cuerpos[1]['uuid'], cuerpos[0]['uuid']);
    expect(cuerpos[1], {
      'uuid': cuerpos[0]['uuid'],
      'vendedor_id': 1,
      'lineas': [
        {'producto_id': 2, 'cantidad': 2},
      ],
      'pago_con': '100.00',
    });

    // Un pedido nuevo lleva otro uuid, y el pago exacto no manda `pago_con`.
    await vender(2, const Dinero.pesos(90));
    expect(cuerpos[2]['uuid'], isNot(cuerpos[0]['uuid']));
    expect(cuerpos[2].containsKey('pago_con'), isFalse);
    expect(
      cuerpos[2]['uuid'],
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });
}
