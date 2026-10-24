-- v2.8.0 · actualizaciones encadenadas e historial de modificaciones (idempotente, correr una vez)
alter table public.events add column if not exists parent_id text;
alter table public.events add column if not exists changes jsonb;
alter table public.events add column if not exists edits jsonb;
create index if not exists events_parent_idx on public.events (parent_id);
