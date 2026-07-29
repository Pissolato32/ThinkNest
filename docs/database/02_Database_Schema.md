# ThinkNest Database Schema (Local Drift & Supabase PostgreSQL)

**Version:** 1.2
**Status:** Approved
**Engines:** Drift (Dart/SQLite) Local & Supabase PostgreSQL Remote
**Changelog:** v1.2 separa o DDL por engine (a v1.1 apresentava um único bloco incorretamente rotulado "PostgreSQL & Drift Compatible", que usava `JSONB` e `gen_random_uuid()` — nenhum dos dois suportado nativamente pelo SQLite) e adiciona RLS às tabelas `project_dna`, `messages` e `documents` (ausentes na v1.1).

---

## 1. DDL — PostgreSQL (Supabase Remote)

```sql
CREATE TABLE public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  category VARCHAR(100),
  maturity_level VARCHAR(50) NOT NULL DEFAULT 'CAPTURED',
  is_pinned BOOLEAN DEFAULT FALSE,
  is_archived BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.project_dna (
  project_id UUID PRIMARY KEY REFERENCES public.projects(id) ON DELETE CASCADE,
  version INT NOT NULL DEFAULT 1,
  dna_json JSONB NOT NULL, -- tipo binário nativo, indexável via GIN
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  role VARCHAR(20) NOT NULL, -- 'user', 'assistant', 'system'
  content TEXT NOT NULL,
  specialist_role VARCHAR(50),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  doc_type VARCHAR(50) NOT NULL, -- 'PRD', 'ARCHITECTURE', 'ROADMAP', 'OUTLINE'
  title VARCHAR(255) NOT NULL,
  content_markdown TEXT NOT NULL,
  version INT NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger de versionamento otimista (ver 02_API_Guidelines.md, seção 5)
CREATE OR REPLACE FUNCTION public.bump_document_version()
RETURNS TRIGGER AS $$
BEGIN
  NEW.version := OLD.version + 1;
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER documents_version_bump
BEFORE UPDATE ON public.documents
FOR EACH ROW EXECUTE FUNCTION public.bump_document_version();
```

## 2. DDL — SQLite / Drift (Local Device)

O SQLite não possui tipo `JSONB` nativo (afinidade de tipo faz fallback para `TEXT`/`NUMERIC`) nem a função `gen_random_uuid()`. IDs são gerados em Dart (`package:uuid`) antes do insert; JSON é sempre armazenado como string.

```sql
CREATE TABLE projects (
  id TEXT PRIMARY KEY NOT NULL,       -- UUID v4 gerado em Dart
  user_id TEXT,
  title TEXT NOT NULL,
  category TEXT,
  maturity_level TEXT NOT NULL DEFAULT 'CAPTURED',
  is_pinned INTEGER NOT NULL DEFAULT 0,  -- boolean como 0/1
  is_archived INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,        -- epoch millis
  updated_at INTEGER NOT NULL
);

CREATE TABLE project_dna (
  project_id TEXT PRIMARY KEY NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  version INTEGER NOT NULL DEFAULT 1,
  dna_json TEXT NOT NULL,             -- JSON serializado (String), decodificado em Dart
  updated_at INTEGER NOT NULL
);

CREATE TABLE messages (
  id TEXT PRIMARY KEY NOT NULL,
  project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  specialist_role TEXT,
  created_at INTEGER NOT NULL
);

CREATE TABLE documents (
  id TEXT PRIMARY KEY NOT NULL,
  project_id TEXT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  doc_type TEXT NOT NULL,
  title TEXT NOT NULL,
  content_markdown TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

Equivalente em Drift (Dart), para a tabela mais sensível ao ponto corrigido:

```dart
class ProjectDna extends Table {
  TextColumn get projectId => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get dnaJson => text()(); // json_serializable no lado do model
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {projectId};
}
```

## 3. Row Level Security (Supabase) — todas as tabelas

A v1.1 habilitava RLS apenas em `projects`; as três tabelas dependentes ficavam sem isolamento por usuário. Corrigido:

```sql
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage their own projects"
ON public.projects FOR ALL
USING (auth.uid() = user_id);

ALTER TABLE public.project_dna ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage DNA of their own projects"
ON public.project_dna FOR ALL
USING (EXISTS (
  SELECT 1 FROM public.projects p
  WHERE p.id = project_dna.project_id AND p.user_id = auth.uid()
));

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage messages of their own projects"
ON public.messages FOR ALL
USING (EXISTS (
  SELECT 1 FROM public.projects p
  WHERE p.id = messages.project_id AND p.user_id = auth.uid()
));

ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage documents of their own projects"
ON public.documents FOR ALL
USING (EXISTS (
  SELECT 1 FROM public.projects p
  WHERE p.id = documents.project_id AND p.user_id = auth.uid()
));
```

## 4. Índices recomendados

```sql
CREATE INDEX idx_documents_project_id ON public.documents(project_id);
CREATE INDEX idx_messages_project_id ON public.messages(project_id);
CREATE INDEX idx_project_dna_gin ON public.project_dna USING GIN (dna_json);
```
