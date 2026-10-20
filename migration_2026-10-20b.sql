-- v2.4.0 · cambio de trailer (idempotente)
alter table public.events add column if not exists from_trailer text;
alter table public.events add column if not exists to_trailer text;
alter table public.events add column if not exists trailer_kind text;
alter table public.events drop constraint if exists events_type_check;
alter table public.events add constraint events_type_check check (type in ('truck_down','day_off','truck_change','trailer_change','transfer','report','note'));
