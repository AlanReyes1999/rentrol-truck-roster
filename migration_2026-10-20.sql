-- v1.9.0 · Ramon Viel + trailers + nombres completos (idempotente, correr una vez en SQL Editor)
alter table public.drivers add column if not exists trailer text;
insert into public.drivers (id, name, truck, trailer, pad) values ('ramon-viel', 'Ramon Viel', '812', 'OMMA 711', 'Sandcan BTA') on conflict (id) do nothing;
insert into public.trucks (id) values ('812') on conflict (id) do nothing;
update public.drivers set name = 'Juan Miguel Aguilar', trailer = coalesce(trailer, 'BD 1019') where id = 'juan-aguilar';
update public.drivers set name = 'Sixto Rafael Florat', trailer = coalesce(trailer, '742') where id = 'rafael-florat';
update public.drivers set trailer = coalesce(trailer, '729') where id = 'miguel-contreras';
update public.drivers set name = 'Roberto Jorge Jaime', trailer = coalesce(trailer, 'OMMA 411') where id = 'roberto-jorge';
update public.drivers set name = 'Cesar Cedeno Rodriguez', trailer = coalesce(trailer, '834') where id = 'cesar-cedeno';
update public.drivers set name = 'Osvaldo Valdes', trailer = coalesce(trailer, 'OMMA 741') where id = 'osaldo-valdez';
update public.drivers set trailer = coalesce(trailer, 'OMMA 864') where id = 'david-villereal';
update public.drivers set name = 'Alain L Aragon Orellana', trailer = coalesce(trailer, 'BD 1020') where id = 'alain-aragon';
update public.drivers set trailer = coalesce(trailer, 'OMMA 725'), pad = coalesce(pad, 'Sandcan BTA') where id = 'roman-trujillo';
alter table public.events add column if not exists planned_time text;
alter table public.events add column if not exists no_eta boolean;
