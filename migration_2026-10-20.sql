-- Roster desde la hoja fuente (nombres completos + Ramon Viel en RTL812)
insert into public.drivers (id, name, carrier, truck, pad, active, start_date) values ('ramon-viel', 'Ramon Viel', 'RENTROL', '812', 'Sandcan BTA', true, '2026-10-17') on conflict (id) do update set name = excluded.name, truck = excluded.truck, pad = excluded.pad, active = true;
update public.drivers set name = 'Juan Miguel Aguilar' where id = 'juan-aguilar';
update public.drivers set name = 'Cesar Cedeno Rodriguez' where id = 'cesar-cedeno';
update public.drivers set name = 'Roberto Jorge Jaime' where id = 'roberto-jorge';
update public.drivers set name = 'Alain L Aragon Orellana' where id = 'alain-aragon';
update public.drivers set name = 'Osvaldo Valdes' where id = 'osaldo-valdez';
update public.drivers set name = 'Sixto Rafael Florat' where id = 'rafael-florat';
update public.trucks set workshop_since = null, ready_since = null where id = '812';
