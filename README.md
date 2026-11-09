# Mi puesto

Punto de venta sencillo para un puesto: vender, cobrar y consultar.
Aplicación Flutter para teléfono y tablet (8.7" en horizontal).

```
flutter run        # abrir la aplicación (PIN de ejemplo: 1234)
flutter test       # correr las pruebas
flutter analyze    # revisar el código
```

## Estado actual

Solo existe el cliente. **Todavía no hay backend**: los datos son de ejemplo,
viven en memoria y se pierden al cerrar la aplicación.

## Cómo está organizado `lib/`

| Carpeta          | Qué contiene |
|------------------|--------------|
| `app/`           | El arranque: `MiPuestoApp` y `Dependencias` (los objetos compartidos). |
| `nucleo/`        | Lo que usan todas las pantallas: colores, tipografía, formato de dinero y fechas, y los widgets básicos (botones, tarjetas, campos). |
| `datos/`         | Los modelos (`Producto`, `Venta`…), los contratos con el backend (`repositorios/`) y sus versiones de mentira (`simulados/`). |
| `controladores/` | El estado que comparten varias pantallas: sesión, catálogo, pedido y ventas. |
| `pantallas/`     | Una carpeta por pantalla. Cada una tiene su archivo `pantalla_*.dart` y una carpeta `widgets/` con sus piezas. |

Reglas que sigue el código:

- **Un widget por archivo**, lo más pequeño posible, con un comentario que
  dice qué es.
- **Nombres en español** y completos; nada de abreviaturas.
- **Claridad antes que rendimiento.**
- Las pantallas nunca hablan con el backend directamente: usan un
  repositorio o un controlador.
- Sin paquetes externos: el estado se maneja con `ChangeNotifier` y
  `ListenableBuilder`, que ya vienen con Flutter.

## Cómo conectar el backend

1. Abre `lib/datos/repositorios/repositorios.dart`. Ahí está la lista
   completa de lo que la aplicación le pide al servidor.
2. Por cada repositorio, crea una clase que lo implemente con llamadas
   reales, por ejemplo
   `class RepositorioDeVentasHttp implements RepositorioDeVentas`.
3. En `lib/datos/conexiones.dart`, agrega un constructor que use esas
   clases y pásalo en `main.dart`: `MiPuestoApp(conexiones: ...)`.

Ninguna pantalla necesita cambiar.

## Pendiente (no está en el diseño todavía)

La pantalla de **Categorías** (crear y editar) ya existe en la app, pero
se hizo sin diseño previo; falta dibujarla en el lienzo. Una categoría
solo se puede eliminar cuando ya no tiene productos.


- Pantalla de **Historial** de ventas.
- **Detalle de una categoría** en Reportes.

Estos dos puntos están marcados en el código con la palabra `PENDIENTE`.

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
