-- Add mutation timestamps required for incremental pull and conflict resolution.
alter table public.conversation_messages
  add column updated_at timestamptz not null default now();

alter table public.ai_tasks
  add column updated_at timestamptz not null default now();
