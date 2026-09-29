-- Preserve the historical migration boundary for the internal SECURITY DEFINER helper.
revoke execute on function public.rls_auto_enable() from anon, authenticated;
