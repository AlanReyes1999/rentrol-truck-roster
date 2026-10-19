-- Correr una vez si ya tenías el esquema anterior (idempotente)
alter table public.trucks add column if not exists workshop_since date;
alter table public.trucks add column if not exists ready_since date;
alter table public.events add column if not exists off_kind text;
alter table public.events add column if not exists planned_end date;
alter table public.events add column if not exists scheduled boolean;
alter table public.events drop constraint if exists events_type_check;
alter table public.events add constraint events_type_check check (type in ('truck_down','day_off','truck_change','transfer','report','note'));
