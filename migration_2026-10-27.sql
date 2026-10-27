-- Rentrol · Truck Roster v2.15.0 · correr UNA vez en Supabase → SQL Editor (se puede repetir sin duplicar)

-- 1) Tipos de evento nuevos: new hire, transfer de compañía y quit
alter table public.events drop constraint if exists events_type_check;
alter table public.events add constraint events_type_check check (type in ('truck_down','day_off','truck_change','trailer_change','transfer','report','note','odometer','new_hire','company_transfer','quit')) not valid;

-- 2) Seguridad: solo los usuarios del equipo pueden leer o escribir datos
create table if not exists public.app_users (email text primary key, role text not null default 'editor', created_at timestamptz default now());
alter table public.app_users enable row level security;
insert into public.app_users (email) select lower(email) from auth.users where email is not null on conflict (email) do nothing;

create or replace function public.rr_is_member() returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.app_users where email = lower(coalesce(auth.jwt() ->> 'email', '')))
$$;

drop policy if exists "rr members read app_users" on public.app_users;
create policy "rr members read app_users" on public.app_users for select to authenticated using (public.rr_is_member());

do $$ declare r record; tb text; begin
  for tb in select tablename from pg_tables where schemaname = 'public' and tablename not in ('app_users', 'push_log') loop
    for r in select policyname from pg_policies where schemaname = 'public' and tablename = tb loop
      execute format('drop policy %I on public.%I', r.policyname, tb);
    end loop;
    execute format('alter table public.%I enable row level security', tb);
    execute format('create policy %I on public.%I for all to authenticated using (public.rr_is_member()) with check (public.rr_is_member())', 'rr members ' || tb, tb);
  end loop;
end $$;

-- Cuentas nuevas @ommatrucking.com quedan autorizadas solas; cualquier otro correo no ve nada
create or replace function public.rr_allow_company_email() returns trigger language plpgsql security definer set search_path = public as $$
begin
  if lower(new.email) like '%@ommatrucking.com' then insert into public.app_users (email) values (lower(new.email)) on conflict (email) do nothing; end if;
  return new;
end $$;
drop trigger if exists rr_allow_company_email on auth.users;
create trigger rr_allow_company_email after insert on auth.users for each row execute function public.rr_allow_company_email();

-- Verificación: debe listar a tu equipo
select email, role from public.app_users order by email;
