-- ThinkNest P1.2 sync baseline
-- Mirrors the local Drift entities and establishes authenticated ownership.

create table public.projects (
  id text primary key,
  user_id text,
  title text not null,
  category text,
  maturity_level text not null default 'CAPTURED',
  is_pinned boolean not null default false,
  is_archived boolean not null default false,
  created_at timestamptz not null,
  updated_at timestamptz not null
);

create table public.project_dna (
  project_id text primary key references public.projects(id) on delete cascade,
  version integer not null default 1,
  dna_json jsonb not null,
  updated_at timestamptz not null
);

create table public.project_snapshots (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  project_version integer not null,
  created_at timestamptz not null,
  reason text not null,
  project_json jsonb not null,
  dna_json jsonb not null
);

create table public.documents (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  type text not null,
  version integer not null,
  status text not null,
  title text not null,
  content text not null,
  dna_version integer not null,
  created_at timestamptz not null,
  updated_at timestamptz not null
);

create table public.conversation_messages (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  role text not null,
  content text not null,
  created_at timestamptz not null,
  provider_id text,
  model text,
  is_pending boolean not null default false
);

create table public.ai_tasks (
  id text primary key,
  project_id text not null references public.projects(id) on delete cascade,
  status text not null default 'PENDING',
  payload_json jsonb not null default '{}'::jsonb,
  attempts integer not null default 0,
  last_error text,
  created_at timestamptz not null
);

create index projects_user_id_updated_at_idx
  on public.projects(user_id, updated_at desc);

create index project_snapshots_project_id_created_at_idx
  on public.project_snapshots(project_id, created_at desc);

create index documents_project_id_updated_at_idx
  on public.documents(project_id, updated_at desc);

create index conversation_messages_project_id_created_at_idx
  on public.conversation_messages(project_id, created_at);

create index ai_tasks_project_id_created_at_idx
  on public.ai_tasks(project_id, created_at);

alter table public.projects enable row level security;
alter table public.project_dna enable row level security;
alter table public.project_snapshots enable row level security;
alter table public.documents enable row level security;
alter table public.conversation_messages enable row level security;
alter table public.ai_tasks enable row level security;

create policy "Users can access their projects"
  on public.projects
  for all
  to authenticated
  using (user_id = (select auth.uid()::text))
  with check (user_id = (select auth.uid()::text));

create policy "Users can access their project DNA"
  on public.project_dna
  for all
  to authenticated
  using (
    exists (
      select 1
      from public.projects
      where projects.id = project_dna.project_id
        and projects.user_id = (select auth.uid()::text)
    )
  )
  with check (
    exists (
      select 1
      from public.projects
      where projects.id = project_dna.project_id
        and projects.user_id = (select auth.uid()::text)
    )
  );

create policy "Users can access their project snapshots"
  on public.project_snapshots
  for all
  to authenticated
  using (
    exists (
      select 1
      from public.projects
      where projects.id = project_snapshots.project_id
        and projects.user_id = (select auth.uid()::text)
    )
  )
  with check (
    exists (
      select 1
      from public.projects
      where projects.id = project_snapshots.project_id
        and projects.user_id = (select auth.uid()::text)
    )
  );

create policy "Users can access their documents"
  on public.documents
  for all
  to authenticated
  using (
    exists (
      select 1
      from public.projects
      where projects.id = documents.project_id
        and projects.user_id = (select auth.uid()::text)
    )
  )
  with check (
    exists (
      select 1
      from public.projects
      where projects.id = documents.project_id
        and projects.user_id = (select auth.uid()::text)
    )
  );

create policy "Users can access their conversation messages"
  on public.conversation_messages
  for all
  to authenticated
  using (
    exists (
      select 1
      from public.projects
      where projects.id = conversation_messages.project_id
        and projects.user_id = (select auth.uid()::text)
    )
  )
  with check (
    exists (
      select 1
      from public.projects
      where projects.id = conversation_messages.project_id
        and projects.user_id = (select auth.uid()::text)
    )
  );

create policy "Users can access their AI tasks"
  on public.ai_tasks
  for all
  to authenticated
  using (
    exists (
      select 1
      from public.projects
      where projects.id = ai_tasks.project_id
        and projects.user_id = (select auth.uid()::text)
    )
  )
  with check (
    exists (
      select 1
      from public.projects
      where projects.id = ai_tasks.project_id
        and projects.user_id = (select auth.uid()::text)
    )
  );
