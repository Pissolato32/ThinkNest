-- rls_auto_enable is an internal SECURITY DEFINER helper and must not be exposed through the Data API.
revoke execute on function public.rls_auto_enable() from anon, authenticated;
