-- Preserve the historical public-execution hardening for the internal helper.
-- The helper is present in the live project but was not part of the reconciled
-- migration baseline, so fresh databases must tolerate its absence.
do $$
begin
  if to_regprocedure('public.rls_auto_enable()') is not null then
    revoke execute on function public.rls_auto_enable() from public;
  end if;
end
$$;
