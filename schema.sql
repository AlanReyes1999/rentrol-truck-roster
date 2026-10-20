-- Rentrol · Truck Roster — esquema Supabase (ejecutar completo en SQL Editor)
create extension if not exists pgcrypto;

create table if not exists public.drivers (
  id text primary key,
  name text not null,
  carrier text default 'RENTROL',
  truck text,
  trailer text,
  pad text,
  active boolean default true,
  start_date date default '2026-10-17',
  notes text,
  updated_at timestamptz default now()
);

create table if not exists public.events (
  id text primary key,
  type text not null check (type in ('truck_down','day_off','truck_change','transfer','report','note')),
  driver_id text references public.drivers(id) on delete set null,
  truck text,
  start_date date not null,
  end_date date,
  start_time text,
  end_time text,
  planned boolean,
  category text,
  reason text,
  note text,
  notified text[] default '{}',
  from_truck text,
  to_truck text,
  from_pad text,
  to_pad text,
  report_type text,
  severity text,
  off_kind text,
  planned_end date,
  planned_time text,
  no_eta boolean,
  scheduled boolean,
  created_by text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.trucks (
  id text primary key,
  active boolean default true,
  workshop_since date,
  ready_since date,
  notes text,
  updated_at timestamptz default now()
);

create index if not exists events_driver_idx on public.events (driver_id);
create index if not exists events_start_idx on public.events (start_date);

-- Solo usuarios autenticados (Alan, JC, Clarissa) leen y escriben
alter table public.drivers enable row level security;
alter table public.events enable row level security;
alter table public.trucks enable row level security;
drop policy if exists "team all trucks" on public.trucks;
create policy "team all trucks" on public.trucks for all to authenticated using (true) with check (true);
drop policy if exists "team all drivers" on public.drivers;
drop policy if exists "team all events" on public.events;
create policy "team all drivers" on public.drivers for all to authenticated using (true) with check (true);
create policy "team all events" on public.events for all to authenticated using (true) with check (true);

-- Tiempo real: cualquier cambio se refleja en los demás navegadores
alter publication supabase_realtime add table public.events;
alter publication supabase_realtime add table public.drivers;
alter publication supabase_realtime add table public.trucks;

insert into public.trucks (id) values ('801'),('802'),('803'),('807'),('808'),('809'),('810'),('811'),('812'),('813'),('814'),('815'),('816'),('817'),('818') on conflict (id) do nothing;

-- Roster inicial (W43 · 2026)
insert into public.drivers (id, name, truck, trailer, pad) values
  ('juan-aguilar', 'Juan Miguel Aguilar', '803', 'BD 1019', 'Bayswater'),
  ('rafael-florat', 'Sixto Rafael Florat', '817', '742', 'Fasken'),
  ('miguel-contreras', 'Miguel Contreras', '815', '729', 'Fasken'),
  ('roberto-jorge', 'Roberto Jorge Jaime', '809', 'OMMA 411', 'Sandcan BTA'),
  ('cesar-cedeno', 'Cesar Cedeno Rodriguez', '807', '834', 'Fasken'),
  ('osaldo-valdez', 'Osvaldo Valdes', '814', 'OMMA 741', 'Sandcan BTA'),
  ('david-villereal', 'David Villereal', '816', 'OMMA 864', 'Sandcan BTA'),
  ('alain-aragon', 'Alain L Aragon Orellana', '811', 'BD 1020', 'Bayswater'),
  ('ramon-viel', 'Ramon Viel', '812', 'OMMA 711', 'Sandcan BTA'),
  ('roman-trujillo', 'Roman Trujillo', '813', 'OMMA 725', 'Sandcan BTA')
on conflict (id) do nothing;

insert into public.events (id, type, driver_id, truck, start_date, end_date, planned, category, reason, from_pad, to_pad, note, created_by) values
  ('seed-td-813', 'truck_down', 'roman-trujillo', '813', '2026-10-17', null, null, 'Mechanical', 'Mechanical - Clutch', null, null, 'Truck en taller · driver en days off mientras', 'Sistema'),
  ('seed-do-roman', 'day_off', 'roman-trujillo', '813', '2026-10-17', null, true, null, null, null, null, 'Days off mientras el 813 está en taller (clutch)', 'Sistema'),
  ('seed-tr-811', 'transfer', 'alain-aragon', '811', '2026-10-18', '2026-10-19', null, null, null, 'Sandcan BTA', 'Bayswater', 'Chassis → Bellydump · cambio de equipo en OMMA Midland Yard, lun 19 oct 9:00 a.m.', 'Sistema')
on conflict (id) do nothing;
