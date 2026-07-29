# ThinkNest Database Schema (Local Drift & Supabase PostgreSQL)

**Version:** 1.1  
**Status:** Approved  
**Engines:** Drift (Dart/SQLite) Local & Supabase PostgreSQL Remote

---

## 1. DDL Schema Definition (PostgreSQL & Drift Compatible)

```sql
CREATE TABLE projects (
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

CREATE TABLE project_dna (
  project_id UUID PRIMARY KEY REFERENCES projects(id) ON DELETE CASCADE,
  version INT NOT NULL DEFAULT 1,
  dna_json JSONB NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  role VARCHAR(20) NOT NULL, -- 'user', 'assistant', 'system'
  content TEXT NOT NULL,
  specialist_role VARCHAR(50),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  doc_type VARCHAR(50) NOT NULL, -- 'PRD', 'ARCHITECTURE', 'ROADMAP', 'OUTLINE'
  title VARCHAR(255) NOT NULL,
  content_markdown TEXT NOT NULL,
  version INT DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

## 2. Row Level Security Policies (Supabase)

```sql
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own projects"
ON projects FOR ALL USING (auth.uid() = user_id);
```
