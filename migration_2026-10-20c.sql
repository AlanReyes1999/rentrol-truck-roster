-- v2.5.0 · Locaciones + flota inactiva con estados, impacto y ubicación (idempotente)
create table if not exists public.locations (
  id text primary key, name text not null, type text default 'yard', description text,
  lat double precision, lng double precision, plus_code text, address text,
  contact text, hours text, capacity text, equipment text[] default '{}', entrance_notes text,
  color text default '#5FC391', updated_at timestamptz default now()
);
alter table public.locations enable row level security;
drop policy if exists "team all locations" on public.locations;
create policy "team all locations" on public.locations for all to authenticated using (true) with check (true);
do $$ begin alter publication supabase_realtime add table public.locations; exception when others then null; end $$;
alter table public.trucks add column if not exists location_id text;
alter table public.trucks add column if not exists location_note text;
alter table public.trucks add column if not exists inactive_reasons text[];
alter table public.events add column if not exists location_id text;
insert into public.locations (id, name, type, lat, lng, plus_code, address, color, equipment) values
  ('omma-yard-midland', 'OMMA Yard, Midland', 'yard', 32.080589, -102.032547, '854V3XJ8+6X', 'Midland, TX', '#5FC391', array['Trucks','Chassis','Belly dump']::text[]),
  ('omma-yard-2-midland', 'OMMA Yard 2, Midland', 'yard', 32.077942, -102.048157, '854V3XH2+5P', 'Midland, TX', '#78A4E3', array['Trucks']::text[]),
  ('omma-yard-kermit', 'OMMA Yard, Kermit', 'yard', 31.857539, -103.070621, '853RVW5H+2Q', 'Kermit, TX', '#EBBD62', array[]::text[]),
  ('gardendale-yard', 'Gardendale Yard', 'yard', 32.049562, -102.302562, '854V2MXW+RX', '2MXW+RXW Gardendale, Texas, EE. UU.', '#A398E6', array['Trucks']::text[])
on conflict (id) do nothing;
insert into public.trucks (id) values ('804'), ('805'), ('806') on conflict (id) do nothing;
update public.trucks set inactive_reasons = array['bad_engine','no_insurance'], location_id = 'omma-yard-2-midland', location_note = 'Chino' where id = '801' and inactive_reasons is null;
update public.trucks set inactive_reasons = array['bad_engine','no_insurance'], location_id = 'omma-yard-midland', location_note = null where id = '802' and inactive_reasons is null;
update public.trucks set inactive_reasons = array['total_loss','no_insurance'], location_id = 'omma-yard-midland', location_note = null where id = '804' and inactive_reasons is null;
update public.trucks set inactive_reasons = array['total_loss','safety_hold','no_insurance'], location_id = null, location_note = 'Safety la recogió' where id = '805' and inactive_reasons is null;
update public.trucks set inactive_reasons = array['crashed','no_insurance'], location_id = 'omma-yard-midland', location_note = null where id = '806' and inactive_reasons is null;
update public.trucks set inactive_reasons = array['bad_engine','no_insurance'], location_id = 'gardendale-yard', location_note = null where id = '808' and inactive_reasons is null;
update public.trucks set inactive_reasons = array['bad_engine','no_insurance'], location_id = 'omma-yard-midland', location_note = null where id = '810' and inactive_reasons is null;
update public.trucks set inactive_reasons = array['bad_engine','no_insurance'], location_id = 'omma-yard-midland', location_note = null where id = '818' and inactive_reasons is null;
update public.locations set lat = 31.857539, lng = -103.070621, plus_code = '853RVW5H+2Q' where id = 'omma-yard-kermit' and lat is null;
