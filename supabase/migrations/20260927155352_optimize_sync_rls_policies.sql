-- Avoid per-row auth.uid() re-evaluation in synchronization RLS policies.
alter policy "Users can access their projects" on public.projects
  using (user_id = (select auth.uid())::text)
  with check (user_id = (select auth.uid())::text);

alter policy "Users can access their project DNA" on public.project_dna
  using (exists (
    select 1 from public.projects
    where projects.id = project_dna.project_id
      and projects.user_id = (select auth.uid())::text
  ))
  with check (exists (
    select 1 from public.projects
    where projects.id = project_dna.project_id
      and projects.user_id = (select auth.uid())::text
  ));

alter policy "Users can access their project snapshots" on public.project_snapshots
  using (exists (
    select 1 from public.projects
    where projects.id = project_snapshots.project_id
      and projects.user_id = (select auth.uid())::text
  ))
  with check (exists (
    select 1 from public.projects
    where projects.id = project_snapshots.project_id
      and projects.user_id = (select auth.uid())::text
  ));

alter policy "Users can access their documents" on public.documents
  using (exists (
    select 1 from public.projects
    where projects.id = documents.project_id
      and projects.user_id = (select auth.uid())::text
  ))
  with check (exists (
    select 1 from public.projects
    where projects.id = documents.project_id
      and projects.user_id = (select auth.uid())::text
  ));

alter policy "Users can access their conversation messages" on public.conversation_messages
  using (exists (
    select 1 from public.projects
    where projects.id = conversation_messages.project_id
      and projects.user_id = (select auth.uid())::text
  ))
  with check (exists (
    select 1 from public.projects
    where projects.id = conversation_messages.project_id
      and projects.user_id = (select auth.uid())::text
  ));

alter policy "Users can access their AI tasks" on public.ai_tasks
  using (exists (
    select 1 from public.projects
    where projects.id = ai_tasks.project_id
      and projects.user_id = (select auth.uid())::text
  ))
  with check (exists (
    select 1 from public.projects
    where projects.id = ai_tasks.project_id
      and projects.user_id = (select auth.uid())::text
  ));
