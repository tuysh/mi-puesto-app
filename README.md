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
# Cuenta: mari@ejemplo.com / pay-de-limon, PIN 1234.
flutter run --dart-define=SIMULADO=true
```

## Cómo se entra

1. **Inicia sesión** o **Crea tu cuenta** (correo y contraseña): una sola
   vez por dispositivo.
2. Una cuenta nueva **crea el PIN del puesto**, escribiéndolo dos veces.
3. De ahí en adelante, al abrir la aplicación solo se pide el **PIN**.
4. **Cerrar sesión** está al fondo de "¿Quién vende hoy?".

`PantallaDeArranque` le pregunta al repositorio de sesión en cuál de esos
pasos va el dispositivo (`EstadoDeAcceso`) y abre la pantalla que toca.

## Cómo está organizado `lib/`

| Carpeta          | Qué contiene |
|------------------|--------------|
| `app/`           | El arranque: `MiPuestoApp` y `Dependencias` (los objetos compartidos). |
| `nucleo/`        | Lo que usan todas las pantallas: colores, tipografía, formato de dinero y fechas, y los widgets básicos (botones, tarjetas, campos). |
| `datos/`         | Los modelos (`Producto`, `Venta`…), los contratos con el backend (`repositorios/`), las implementaciones que llaman al servidor (`http/`) y sus versiones de mentira (`simulados/`). |
| `controladores/` | El estado que comparten varias pantallas: sesión, catálogo, pedido y ventas. |
| `pantallas/`     | Una carpeta por pantalla. Cada una tiene su archivo `pantalla_*.dart` y una carpeta `widgets/` con sus piezas. |

Reglas que sigue el código:

- **Un widget por archivo**, lo más pequeño posible, con un comentario que
  dice qué es.
- **Nombres en español** y completos; nada de abreviaturas.
- **Claridad antes que rendimiento.**
- Las pantallas nunca hablan con el backend directamente: usan un
  repositorio o un controlador.
- Casi sin paquetes externos: el estado se maneja con `ChangeNotifier` y
  `ListenableBuilder`, que ya vienen con Flutter. Los únicos paquetes son
  `http` (hablar con el servidor) y `flutter_secure_storage` (guardar la
  sesión cifrada en el dispositivo).

## Cómo habla con el servidor

La especificación de la API está en el repositorio del backend
(`docs/api-v1.md`). De este lado:

1. `lib/datos/repositorios/repositorios.dart` declara todo lo que la
   aplicación le pide al servidor.
2. `lib/datos/http/` lo implementa: un `Repositorio…Http` por cada
   contrato. Todos comparten `ClienteDeApi`, que arma las direcciones,
   manda el token de la sesión y convierte los errores del servidor en
   `ErrorDelServidor` (con el mensaje listo para mostrar).
3. `lib/datos/conexiones.dart` junta los repositorios: `Conexiones.http`
   o `Conexiones.simuladas`. Las pantallas no saben cuál les tocó.

Cosas que conviene saber:

- **Sesión.** Al entrar, el servidor da un token; se guarda cifrado en el
  dispositivo junto con el id del puesto. Si el servidor deja de
  reconocerlo (401), la aplicación vuelve sola a "Inicia sesión".
- **Dinero.** Viaja como texto (`"45.00"`) y se convierte a centavos sin
  pasar por decimales (`conversion_de_json.dart`).
- **Ventas.** Cada venta lleva un identificador único; si se queda sin
  respuesta por mala señal y se reintenta el mismo pedido, se reúsa para
  que no se registre doble.
- **Caja.** El servidor permite vender sin caja abierta, pero esas ventas
  no entran en la cuenta. Por eso "Cerrar caja" ofrece abrirla cuando no
  hay ninguna.
- **Gráfica "Por hora".** El servidor resume por día; las barras por hora
  de Reportes › Día se arman sumando las ventas de hoy.

`test/servidor_real_test.dart` prueba todo esto contra un servidor de
verdad (viene explicado ahí mismo; normalmente se salta).

## Pendiente (no está en el diseño todavía)

La pantalla de **Categorías** (crear y editar) y el formulario de
**Abrir caja** ya existen en la app, pero se hicieron sin diseño previo;
falta dibujarlos en el lienzo. Una categoría
solo se puede eliminar cuando ya no tiene productos.


- Pantalla de **Historial** de ventas.
- **Detalle de una categoría** en Reportes.
- **Recuperar la contraseña** ("Olvidé mi contraseña" en Inicia sesión);
  tampoco existe todavía en el servidor.

Estos puntos están marcados en el código con la palabra `PENDIENTE`.

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
