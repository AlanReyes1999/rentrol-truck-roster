# Rentrol · Truck Roster

Portal de gestión de drivers y trucks de Rentrol (Meds Logistics): roster general con porcentaje de actividad, perfiles por driver y por truck, calendario de eventos (truck down, days off, cambios de camión, transfers y reportes) y el generador de imagen + WhatsApp para transfers.

Semanas **sábado → viernes**, numeradas por año (W43 · 2026 es la primera con datos). Eventos con horas ponderan contra turno de 12 h. Solo truck down y days off restan actividad.

## Archivos

- `index.html` — portal (un solo archivo, no necesita build)
- `transfer.html` — generador de imagen y mensaje de transfer
- `config.json` — URL y llave pública de Supabase + nombres por correo
- `supabase/schema.sql` — tablas, seguridad, tiempo real y roster inicial
- `netlify.toml` — configuración de publicación

Sin `config.json` lleno, el portal corre en **modo local** (datos solo en ese navegador) para pruebas.

## 1. Supabase (10 min, plan gratuito)

1. Crea un proyecto en https://supabase.com (región US East).
2. **SQL Editor → New query**: pega todo `supabase/schema.sql` y ejecuta.
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

## Uso diario

- **Inicio**: saludo, foto del día (actividad, activos, trucks en taller, alertas abiertas), módulos y alertas de hoy. El menú lateral se despliega al pasar el cursor por el borde izquierdo o con el botón de menú; el pin lo deja fijo. Abajo del menú: modo día / noche.
- **Roster**: actividad de la flota = drivers con truck activos hoy entre drivers con truck (conteo individual, no por días) (semana actual, pasada, mes, todo o semana/rango a elegir), estado de hoy, franja de días por driver (verde activo, rojo truck down, ámbar days off, contorno = programado a futuro) y calendario con filtros por tipo. Clic en ↗ o en el nombre abre el perfil. Los selectores de truck, pad y estado se editan ahí mismo y generan el evento correspondiente (cambio de camión, transfer o truck down / day off / reporte) con la nota *Modificado desde Roster*. Trucks sin driver quedan **En taller (At workshop)** automáticamente.
- **+ Nuevo evento**: driver → truck automático → tipo. Days off: programado sí/no, fechas, horas opcionales, a quién se notificó. Truck down: categoría y motivo, inicio, cerrado o abierto. Al cerrar un evento salen los días perdidos.
- **Eventos**: lista filtrable y exportable a CSV; cada evento se edita, cierra o elimina.
- **Transfers**: imagen para gerencia (EN) y mensaje de WhatsApp (ES). Desde un evento de tipo Transfer, *Imagen para gerencia* abre el generador ya prellenado.
- **Resumen WhatsApp** (en Roster): texto listo con actividad, abiertos y porcentaje por driver.
