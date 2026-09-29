-- Preserve the historical migration boundary for the internal SECURITY DEFINER helper.
-- The helper is present in the live project but was not part of the reconciled
-- migration baseline, so fresh databases must tolerate its absence.
do $$
begin
  if to_regprocedure('public.rls_auto_enable()') is not null then
    revoke execute on function public.rls_auto_enable() from anon, authenticated;
  end if;
end
$$;
