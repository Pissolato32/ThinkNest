create index if not exists ai_tasks_pending_idx on public.ai_tasks (status, created_at) where status = 'PENDING';
create index if not exists ai_tasks_project_updated_idx on public.ai_tasks (project_id, updated_at desc);
create index if not exists conversation_messages_project_created_idx on public.conversation_messages (project_id, created_at);