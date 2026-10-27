-- Truck Roster v2.13 · Bitácora de cambios (idempotente, correr una vez en SQL Editor)
create table if not exists public.audit_log (
  id text primary key, at timestamptz default now(), by_name text, by_email text,
  tbl text, op text, rec_id text, before jsonb, after jsonb, revert_of text
);
create index if not exists audit_log_at_idx on public.audit_log (at desc);
alter table public.audit_log enable row level security;
drop policy if exists "team audit" on public.audit_log;
create policy "team audit" on public.audit_log for all to authenticated using (true) with check (true);
do $$ begin alter publication supabase_realtime add table public.audit_log; exception when others then null; end $$;
