# Mi puesto

Punto de venta sencillo para un puesto: vender, cobrar y consultar.
Aplicación Flutter para teléfono y tablet (8.7" en horizontal).

```
flutter run        # abrir la aplicación, conectada al servidor
flutter test       # correr las pruebas
flutter analyze    # revisar el código
```

La aplicación habla con el servidor `https://mi-puesto-back.lunita.me`
(la dirección está en `lib/main.dart`). Dos variantes útiles al programar:

```
# Otro servidor, por ejemplo el backend en tu computadora
# (10.0.2.2 es "tu computadora" vista desde el emulador de Android):
flutter run --dart-define=SERVIDOR=http://10.0.2.2:8000

# Sin servidor: datos de ejemplo que viven en memoria.
# Cuenta: mari@ejemplo.com / pay-de-limon.
# PIN de Mari (dueña) 1234, de Lupe 1111 y de Toño 2222.
flutter run --dart-define=SIMULADO=true
```

## Cómo se entra

1. **Inicia sesión** o **Crea tu cuenta** (nombre del negocio, correo y
   contraseña): una sola vez por dispositivo.
2. Una cuenta nueva **crea el PIN de la dueña** (escribiéndolo dos veces)
   y dice **cómo se llama**.
3. De ahí en adelante, al abrir la aplicación sale **¿Quién vende hoy?**:
   cada persona toca su nombre y escribe **su propio PIN**.
4. Para que entre otra persona se toca el nombre de quien está dentro
   (arriba a la derecha en "Vender"). **Cerrar sesión** está en "Más".

`PantallaDeArranque` le pregunta a la sesión en cuál de esos pasos va el
dispositivo (`EstadoDeAcceso`) y abre la pantalla que toca.

## Quién puede qué

Hay dos papeles (`Rol`):

- **La dueña** ve todo: Vender, Hoy, Reportes y Más (ventas del día,
  gastos, cierres, productos, categorías y personas).
- **Quien solo vende** ve dos pestañas: Vender y Mis ventas.

La aplicación esconde lo que no toca (`Sesion.esDuena`), pero quien decide
de verdad es el servidor: si alguien que solo vende pide algo de la dueña,
responde con un error.

## La caja manda

Sin caja abierta nadie puede vender. Por eso "Vender" revisa primero la
caja (`ControladorDeCaja`):

- cerrada y está la dueña → el formulario para abrirla;
- cerrada y está quien solo vende → un aviso de que pida abrirla;
- abierta desde un día anterior → le pide a la dueña cerrarla.

La caja se cierra desde "Hoy". Cerrar es definitivo: las ventas y los
gastos de ese día ya no se pueden cambiar.

## Cómo está organizado `lib/`

| Carpeta          | Qué contiene |
|------------------|--------------|
| `app/`           | El arranque: `MiPuestoApp` y `Dependencias` (los objetos compartidos). |
| `nucleo/`        | Lo que usan todas las pantallas: colores, tipografía, formato de dinero y fechas, y los widgets básicos (botones, tarjetas, campos, listas). |
| `datos/`         | Los modelos (`Producto`, `Venta`…), los contratos con el backend (`repositorios/`), las implementaciones que llaman al servidor (`http/`) y sus versiones de mentira (`simulados/`). |
| `controladores/` | El estado que comparten varias pantallas: sesión, catálogo, caja, pedido y ventas. |
| `pantallas/`     | Una carpeta por tema. Cada una tiene sus archivos `pantalla_*.dart` y una carpeta `widgets/` con sus piezas. |

Las carpetas de `pantallas/` siguen el orden del diseño:

| Carpeta       | Pantallas |
|---------------|-----------|
| `acceso/`     | Iniciar sesión, crear cuenta, crear PIN, tu nombre, ¿quién vende hoy? y el PIN de cada persona. |
| `principal/`  | El marco con el menú (barra abajo en teléfono, riel a la izquierda en tablet). |
| `vender/`     | Vender (teléfono y tablet), elegir tamaño y el pedido. |
| `cobrar/`     | Cobrar y lo que comparte con el panel de tablet. |
| `caja/`       | Abrir caja, cerrar caja, el resumen del cierre y los cierres anteriores. |
| `hoy/`        | Cómo va el día. |
| `ventas/`     | Ventas del día, detalle, editar venta y "Mis ventas". |
| `gastos/`     | La lista de gastos y anotar o editar uno. |
| `reportes/`   | Reportes y el PDF. |
| `mas/`        | El menú "Más". |
| `productos/`  | La lista (teléfono y tablet), el formulario y "¿Cómo se ve al vender?". |
| `categorias/` | Categorías de productos y de gastos. |
| `personas/`   | Personas y editar persona. |

Reglas que sigue el código:

- **Un widget por archivo**, lo más pequeño posible, con un comentario que
  dice qué es.
- **Nombres en español** y completos; nada de abreviaturas.
- **Claridad antes que rendimiento.**
- Las pantallas nunca hablan con el backend directamente: usan un
  repositorio o un controlador.
- Casi sin paquetes externos: el estado se maneja con `ChangeNotifier` y
  `ListenableBuilder`, que ya vienen con Flutter. Los únicos paquetes son
  `http` (hablar con el servidor), `flutter_secure_storage` (guardar la
  sesión cifrada en el dispositivo), `image_picker` (tomar o elegir la
  foto de un producto) y `pdf` con `printing` (armar y compartir el PDF
  del reporte).

## Cómo habla con el servidor

La especificación de la API está en el repositorio del backend
(`docs/api-v2.md`). De este lado:

1. `lib/datos/repositorios/repositorios.dart` declara todo lo que la
   aplicación le pide al servidor.
2. `lib/datos/http/` lo implementa: un `Repositorio…Http` por cada
   contrato. Todos comparten `ClienteDeApi`, que arma las direcciones,
   manda el token de la sesión y convierte los errores del servidor en
   `ErrorDelServidor` (con el mensaje listo para mostrar).
3. `lib/datos/simulados/` hace lo mismo en memoria. Todos sus
   repositorios comparten un `ServidorSimulado`, que sigue las mismas
   reglas que el de verdad (quién puede qué, la cuenta de la caja…).
4. `lib/datos/conexiones.dart` junta los repositorios: `Conexiones.http`
   o `Conexiones.simuladas`. Las pantallas no saben cuál les tocó.

Cosas que conviene saber:

- **Sesión.** Al entrar, el servidor da un token; se guarda cifrado en el
  dispositivo. Quién está dentro (el perfil activo) lo recuerda el
  servidor. Si deja de reconocer el token (401), la aplicación vuelve sola
  a "Inicia sesión"; si responde que no hay nadie dentro (`sin_perfil`),
  vuelve a "¿Quién vende hoy?".
- **Errores.** `ErrorDelServidor.mensaje` se muestra tal cual.
  `ErrorDelServidor.codigo` (`sin_caja`, `pin_incorrecto`…) es para que
  la aplicación decida qué hacer. Sin internet se lanza `ErrorDeConexion`,
  y las pantallas que cargan datos muestran "No hay internet".
- **Dinero.** Viaja como texto (`"45.00"`) y se convierte a centavos sin
  pasar por decimales (`conversion_de_json.dart`).
- **Productos.** Un producto tiene UN precio o VARIOS tamaños
  (`presentaciones`), nunca los dos. Cada tamaño es su propio renglón en
  el pedido. "Hay hoy" (`disponible`) apagado deja el producto a la vista,
  pero sin poder agregarlo; desactivarlo lo saca de la aplicación.
- **Ventas.** Los precios nunca se mandan: los pone el servidor. Cada
  venta lleva un identificador único; si se queda sin respuesta por mala
  señal y se reintenta el mismo pedido, se reúsa para que no se registre
  doble. Una venta no se borra: la dueña la edita o la cancela, y queda
  dicho quién y cuándo.
- **Imagen del producto.** Un producto se ve con foto, emoji o letras
  (se elige en la hoja "¿Cómo se ve al vender?"); el servidor dice cuál
  con `representacion`. El emoji y las letras se guardan con el producto;
  la foto se sube aparte, después de guardarlo. Si la foto no carga (sin
  internet), se ve el emoji o las letras.
- **Colores.** Las categorías y las personas traen un número de color de
  0 a 4; el pastel que le toca a cada número está en `Pasteles.todos`.
- **Resumen.** "Hoy", "Reportes" y el PDF salen de la misma ruta
  (`/resumen`), y cada pantalla pide solo las secciones que pinta.
- **PDF.** Lo arma la aplicación (`crear_pdf_del_reporte.dart`) con los
  datos del resumen; el servidor no entrega PDF.

`test/servidor_real_test.dart` prueba todo esto contra un servidor de
verdad (viene explicado ahí mismo; normalmente se salta).

## Diferencias con el diseño

Cosas que se resolvieron distinto al lienzo, y por qué:

- **Abrir caja** y **Caja sin abrir** conservan el menú de abajo: una
  dueña que acaba de crear su cuenta necesita llegar a "Más" para dar de
  alta sus productos antes de abrir la caja.
- **"Antes cierra la caja de ayer"** tiene además el enlace "Seguir
  vendiendo por ahora", para un puesto que sigue abierto pasada la
  medianoche.
- En tablet, **Productos** lleva una flecha para volver a "Más".

## Pendiente

- **Editar venta** deja cambiar cantidades, quitar renglones, el método
  de pago y la nota, pero no agregar productos que la venta no tenía.
- No hay dónde ver ni reactivar los **productos desactivados** (el
  servidor sí lo permite con `GET /productos?activo=0`).
- **Recuperar la contraseña** y **recuperar el PIN de la dueña**: no
  existen todavía en el servidor.

Lo que es de código está marcado con la palabra `PENDIENTE`.

## Tipografías

Figtree y Bricolage Grotesque (licencia SIL Open Font; ver
`assets/fuentes/`).

## Icono de la aplicación

El icono es el mismo emblema de la pantalla del PIN (`LogoDelPuesto`). No se
dibuja a mano: se genera a partir del widget, para Android, iOS y web, con

```
flutter test herramientas/generar_iconos.dart
```

Si cambias el logo o los colores, vuelve a ejecutarlo. La imagen original
queda en `assets/icono/icono.png`.
