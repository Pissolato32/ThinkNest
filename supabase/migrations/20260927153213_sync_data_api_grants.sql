-- Expose synchronization tables to authenticated clients through the Data API.
-- RLS policies remain the row-level authorization boundary.
grant select, insert, update, delete on public.projects to authenticated;
grant select, insert, update, delete on public.project_dna to authenticated;
grant select, insert, update, delete on public.project_snapshots to authenticated;
grant select, insert, update, delete on public.documents to authenticated;
grant select, insert, update, delete on public.conversation_messages to authenticated;
grant select, insert, update, delete on public.ai_tasks to authenticated;
