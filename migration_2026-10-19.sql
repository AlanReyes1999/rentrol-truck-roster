-- Solo si ya corriste schema.sql antes de esta fecha: agrega seguimiento (notas) y fecha de taller
alter table public.trucks add column if not exists workshop_since date;
alter table public.events drop constraint if exists events_type_check;
alter table public.events add constraint events_type_check check (type in ('truck_down','day_off','truck_change','transfer','report','note'));
