-- v2.5.1 · Sin seguro para todas las unidades sin driver (idempotente)
update public.trucks t set inactive_reasons = array_append(coalesce(t.inactive_reasons, '{}'), 'no_insurance')
where not exists (select 1 from public.drivers d where coalesce(d.active, true) and d.truck = t.id)
  and not ('no_insurance' = any(coalesce(t.inactive_reasons, '{}')));
