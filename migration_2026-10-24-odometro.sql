-- Rentrol · Truck Roster v2.10 · Odómetro (correr UNA vez en Supabase → SQL Editor → New query → Run)
alter table public.events add column if not exists odometer numeric;
alter table public.events add column if not exists photo_url text;
alter table public.events add column if not exists odo_source text;
alter table public.events add column if not exists odo_conf numeric;
alter table public.events drop constraint if exists events_type_check;

-- Carpeta de fotos del tablero (Storage)
insert into storage.buckets (id, name, public) values ('odometer', 'odometer', true) on conflict (id) do nothing;
drop policy if exists "rr odo read" on storage.objects;
create policy "rr odo read" on storage.objects for select using (bucket_id = 'odometer');
drop policy if exists "rr odo insert" on storage.objects;
create policy "rr odo insert" on storage.objects for insert to authenticated with check (bucket_id = 'odometer');
drop policy if exists "rr odo update" on storage.objects;
create policy "rr odo update" on storage.objects for update to authenticated using (bucket_id = 'odometer');
drop policy if exists "rr odo delete" on storage.objects;
create policy "rr odo delete" on storage.objects for delete to authenticated using (bucket_id = 'odometer');

-- Primera lectura: 803 · Juan Miguel Aguilar · 528,840 mi (foto por WhatsApp)
insert into public.events (id, type, driver_id, truck, start_date, start_time, end_date, odometer, photo_url, odo_source, note, created_by, created_at, updated_at)
values ('odo-803-20261024', 'odometer', null, '803', '2026-10-24', '00:25', '2026-10-24', 528840, 'https://rentrol-truck-roster.netlify.app/odometer-seed/803-2026-10-24.jpg', 'manual', 'Foto enviada por Juan Miguel Aguilar (WhatsApp)', 'Alan', now(), now())
on conflict (id) do nothing;
