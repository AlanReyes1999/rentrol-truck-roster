# Rentrol · Truck Roster · v2.7.7

Portal de gestión de drivers y trucks de Rentrol (Meds Logistics): roster general con porcentaje de actividad, perfiles por driver y por truck, calendario de eventos (truck down, days off, cambios de camión, transfers y reportes) y el generador de imagen + WhatsApp para transfers.

Semanas **sábado → viernes**, numeradas por año (W43 · 2026 es la primera con datos). Eventos con horas ponderan contra turno de 12 h. Solo truck down y days off restan actividad.

## Archivos

- `index.html` — portal (un solo archivo, no necesita build)
- `transfer.html` — generador de imagen y mensaje de transfer
- `config.json` — URL y llave pública de Supabase + nombres por correo (vive solo en el repo; no se incluye en las entregas para no pisar tus llaves)
- `schema.sql` — tablas, seguridad, tiempo real y roster inicial
- `netlify.toml` — configuración de publicación
- `favicon.svg`, `favicon-32.png`, `apple-touch-icon.png`, `icon-192.png`, `icon-512.png`, `manifest.webmanifest` — icono del portal y app en celular

Todos los archivos van sueltos en la raíz del repo (sin carpetas).

Sin `config.json` lleno, el portal corre en **modo local** (datos solo en ese navegador) para pruebas.

## 1. Supabase (10 min, plan gratuito)

1. Crea un proyecto en https://supabase.com (región US East).
2. **SQL Editor → New query**: pega todo `schema.sql` y ejecuta. (Si ya lo habías corrido antes, ejecuta además `migration_2026-10-19.sql`.)
3. **Authentication → Providers → Email**: desactiva *Allow new users to sign up* (solo entran los usuarios que tú crees).
4. **Authentication → Users → Add user → Create new user**: crea a Alan, JC y Clarissa con correo + contraseña y marca *Auto Confirm User*.
5. **Project Settings → API**: copia *Project URL* y *anon public key* a `config.json`:

```json
{
  "supabaseUrl": "https://xxxx.supabase.co",
  "supabaseAnonKey": "eyJ...",
  "names": { "alan@ommatrucking.com": "Alan", "jc@ommatrucking.com": "JC", "clarissa@ommatrucking.com": "Clarissa" }
}
```

`names` convierte el correo en el nombre que queda registrado en cada evento (*Registrado por*). La llave anon es pública por diseño; la seguridad la dan las políticas RLS del esquema (solo usuarios autenticados).

## 2. GitHub

Repositorio: `AlanReyes1999/rentrol-truck-roster` (rama `main`). Desde la carpeta con estos archivos:

```bash
git init
git add .
git commit -m "Rentrol Truck Roster v1"
git branch -M main
git remote add origin https://github.com/AlanReyes1999/rentrol-truck-roster.git
git push -u origin main
```

## 3. Netlify

1. **Add new site → Import an existing project → GitHub →** elige el repo.
2. Build command: vacío. Publish directory: `.` (ya viene en `netlify.toml`).
3. Deploy. Cada `git push` republica.

Opcional: **Authentication → URL Configuration** en Supabase → *Site URL* = tu dominio de Netlify.

## Móvil y app

El portal es responsivo: en celular la navegación es una barra inferior de 6 pestañas (como app nativa) y arriba quedan marca, idioma, tema y usuario; Inicio muestra 4 indicadores en dos columnas, el roster se muestra en tarjetas, Drivers y Trucks se eligen con un selector, los formularios van a una columna y el generador de transfer abre a pantalla completa. En el teléfono abre la URL y usa **Agregar a pantalla de inicio** (Safari: Compartir → Agregar a inicio; Chrome: menú ⋮ → Agregar a pantalla principal): queda con el icono del camión y abre a pantalla completa. En computadora puedes previsualizar la versión móvil agregando `?mobile=1` a la URL.

## Taller y seguimiento

En Roster, la píldora **Flota activa / En taller** cambia de vista. Un truck sin driver queda en taller automáticamente: se marca cada día desde la fecha en que perdió driver (o desde W43 si nunca tuvo), con alerta. Desde ahí se agregan comentarios de seguimiento, se asigna driver o se registra truck down. Al pasar el cursor por un nombre o un número de truck se ven sus eventos activos, último evento y último comentario; en los perfiles aparece el mismo contexto con la caja de seguimiento.

## Colores

Verde activo · rojo truck down y day off no programado · azul day off programado · amarillo transfer · morado reporte · rojo intenso taller · verde esmeralda listo para asignar. En el calendario, truck downs y days off toman el color de su alerta tal como estaba ese día (verde en tiempo, ámbar al límite, rojo excedido).

## v1.7.0

Corre `migration_2026-10-20.sql` en Supabase: agrega a Ramon Viel (RTL812) y pone los nombres completos de la hoja fuente. Al cerrar un truck down o day off, el driver vuelve a *Activo* ese mismo día y la celda queda parcial (con horas, proporcional; sin horas, medio día).

## Days off (tarjeta del Roster)

Muestra los drivers en day off **hoy** sobre los drivers con truck: verde por debajo del 15 %, ámbar entre 15 y 20 %, rojo por encima del 20 % (con pulso). Debajo: con cuántos cierra la semana y la tendencia (▲ más fuera, ▼ menos), y para el periodo elegido las salidas, los regresos (reales o programados) y el balance regresos/salidas: 100 % verde, 80–99 % ámbar, menos de 80 % rojo con la nota "Más salidas que regresos".

El calendario proyecta los eventos abiertos hacia adelante (un day off que ya pasó su límite sigue en rojo con los días de más) y, con el filtro *En taller*, muestra por día los trucks en taller con sus días acumulados.

## Alertas y tiempos

- **Truck down**: verde 0–12 h, ámbar 12–24 h, rojo más de 24 h (con horas usa la hora real; sin horas, desde que se registró).
- **Day off**: al crearlo eliges *Reset day* (2 días) o *Week off* (7 días). En tiempo = verde, último día = ámbar, excedido = rojo con los días de más. Un day off abierto lleva *Regreso programado* o **Sin ETA** (se marca inactivo día a día y en el calendario hasta fin de mes, hasta que haya fecha o regreso), y aparece en el calendario y en la tarjeta *Salidas y regresos* (etiquetas Salida / Regreso / Regreso prog. / Fuera según la semana filtrada).
- **Truck down programado**: estado *Programado* con fin programado opcional; se ve en el calendario y pasa a activo al llegar la fecha.
- **Taller**: trucks sin driver; ámbar la primera semana, rojo después de 7 días. Desde la vista *En taller* (mismo diseño que la flota activa, con % de disponibilidad) se cambia a *Listo para asignar*, se asigna driver y se abre el **hilo de seguimiento** (comentarios y eventos en orden, con hora, autor y tiempo entre pasos). El hilo también está en los perfiles de driver y truck.

## Avisos en el celular

En **Cuenta** (tocar el avatar) activa *Avisos en este dispositivo*. El portal revisa cada 5 minutos y al volver a la app: truck down que pasa de 12 h y de 24 h, day off en su último día o excedido, y trucks con más de 7 días en taller. Cada aviso se manda una sola vez por día y por nivel. Para que lleguen con la app cerrada en el teléfono, instálala en la pantalla de inicio (Android) y mantén la sesión iniciada.

## Sin conexión

El portal funciona sin señal: la pantalla se guarda en el teléfono (`sw.js`), los datos quedan en caché y cada cambio que hagas offline se encola y se envía solo al volver la conexión (aviso arriba con los cambios pendientes y botón *Sincronizar ahora*). Tocar el avatar abre la cuenta: estado de conexión, última sincronización, idioma, tema y cerrar sesión.

## Atajos y gestos (v2.0)

- **Buscar** (⌘K / Ctrl+K o la lupa en celular): driver, truck o evento; Enter abre el primero.
- **Acciones rápidas**: botón ⋯ en la fila (PC) o mantener presionado el nombre (celular): Truck down, Day off, Regresó / cerrar abiertos, Seguimiento.
- **Deshacer**: tras guardar, cerrar o eliminar, el aviso trae *Deshacer* durante 6 s.
- **Gestos en celular**: deslizar hacia abajo cierra la hoja del formulario y los paneles; deslizar a los lados cambia el mes del calendario; jalar hacia abajo en la parte superior actualiza; vibración ligera al guardar.
- **Fechas rápidas**: Ayer / Hoy / Mañana sobre el campo de inicio.
- Modo noche automático la primera vez (20:00–6:00 o según el sistema); después manda tu elección.

## Locaciones y flota inactiva (v2.5)

- **Locaciones**: yardas, talleres, plantas de arena, pozos. Basta nombre + coordenadas; se pueden pegar coordenadas, un link de Google Maps o un Plus Code (también corto, p. ej. `2MXW+RXW Gardendale, TX`). Se usan en los transfers y para ubicar unidades detenidas.
- **Flota inactiva** (antes taller): cada unidad sin driver lleva uno o varios estados (Bad engine, Chocada, Pérdida total, Sin seguro…) con impacto automático (Crítico/Alto/Medio/Bajo), ubicación y su hilo. Al cambiar de camión, el portal pregunta dónde quedó el que se dejó.
- Correr `migration_2026-10-20c.sql` una vez en Supabase.

## Actividad ponderada y notificaciones (v2.6)

- **Actividad por evento**: el día de un transfer, cambio de truck o cambio de trailer cuenta 50 %. Truck down y days off con horas se miden sobre 24 h (12 h perdidas = 50 %); el día de regreso con hora cuenta solo hasta esa hora; sin hora, medio día. El % de flota es el promedio real de cada driver, no un conteo.
- **Notificaciones**: campana con contador (menú en PC, barra superior en celular). Cada evento nuevo o comentario en un hilo de otro usuario aparece como aviso breve; las alertas de tiempo (truck down >12/24 h, day off excedido, unidad inactiva >7 días) salen con su propia animación, vibración y sonido. *Probar* lanza un ejemplo; *Sonido* lo enciende o apaga.
- **Celular**: deslizar hacia abajo cierra la hoja solo si estás arriba del todo (ya no se cierra al regresar el scroll); encabezado compacto al bajar; tarjetas del roster a una columna.

## Push (v2.7)

Alertas con la app cerrada: sigue `push-setup/PASOS.md` (función `rr-push`, secretos y `push_setup.sql` en Supabase). Requiere `sw.js` y `badge-96.png` en el repo. En iPhone solo funciona con la app instalada en la pantalla de inicio (iOS 16.4+).

## Actualizaciones

Cada versión trae `version.json`. Al subirlo junto con `index.html`, quien tenga la app abierta ve la ventana *Nueva versión disponible* y se actualiza con un toque (revisa cada 5 min y al volver a la app).

## Uso diario

- **Inicio**: saludo, foto del día (actividad, activos, trucks en taller, alertas abiertas), módulos y alertas de hoy. El menú lateral se despliega al pasar el cursor por el borde izquierdo o con el botón de menú; el pin lo deja fijo. Abajo del menú: modo día / noche.
- **Roster**: actividad de la flota = promedio del rango de la actividad diaria (drivers con truck activos ÷ drivers con truck); cada día de la franja y del calendario muestra su propio %, con el día y la semana actuales resaltados en verde (semana actual, pasada, mes, todo o semana/rango a elegir), estado de hoy, franja de días por driver (verde activo, rojo truck down, ámbar days off, contorno = programado a futuro) y calendario con filtros por tipo. Clic en ↗ o en el nombre abre el perfil. Los selectores de truck, pad y estado se editan ahí mismo y generan el evento correspondiente (cambio de camión, transfer o truck down / day off / reporte) con la nota *Modificado desde Roster*. Trucks sin driver quedan **En taller (At workshop)** automáticamente.
- **+ Nuevo evento**: driver → truck automático → tipo. Days off: programado sí/no, fechas, horas opcionales, a quién se notificó. Truck down: categoría y motivo, inicio, cerrado o abierto. Al cerrar un evento salen los días perdidos.
- **Eventos**: lista filtrable y exportable a CSV; cada evento se edita, cierra o elimina.
- **Transfers**: imagen para gerencia (EN) y mensaje de WhatsApp (ES); el botón *Registrar en Truck Roster* dentro del generador abre el evento ya prellenado, y abajo queda el historial de transfers (también aparecen en el calendario). Desde un evento de tipo Transfer, *Imagen para gerencia* abre el generador ya prellenado.
- **Resumen WhatsApp** (en Roster): texto listo con actividad, abiertos y porcentaje por driver.
