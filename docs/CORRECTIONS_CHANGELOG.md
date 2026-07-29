# ThinkNest — Changelog de Correções de Documentação

**Referência:** auditoria técnica realizada em 2026-07-29 sobre `docs/backend/02_API_Guidelines.md` (v1.1), `docs/database/02_Database_Schema.md` (v1.1) e `docs/testing/02_Acceptance_Criteria.md` (v1.0).
**Escopo desta correção:** os dois primeiros arquivos, que concentraram os achados de completude e correção técnica, e posteriormente a inclusão do Produto Flow e metadados de repositório.

## Mapeamento achado → correção

| # | Achado da auditoria | Critério afetado | Correção aplicada | Status |
|---|---|---|---|---|
| 1 | `02_API_Guidelines.md` documentava apenas 1 endpoint (`/ai-gateway-stream`) para um schema com 4 entidades | Completude | Adicionados contratos REST completos para `projects`, `documents`, `messages` (seção 2 da v1.2) | **Corrigido** |
| 2 | Endpoint SSE sem headers, schema de eventos ou comportamento de desconexão | Completude | Especificados headers de resposta, schema de eventos (`token`/`specialist_change`/`done`/`error`) e política de reconexão (seção 3 da v1.2) | **Corrigido** |
| 3 | DDL único rotulado "PostgreSQL & Drift Compatible" usando `JSONB` (inexistente nativamente em SQLite) | Correção técnica | DDL separado em duas seções distintas — PostgreSQL e SQLite/Drift — cada uma com os tipos corretos do seu engine | **Corrigido** |
| 4 | Mesmo bloco DDL usava `gen_random_uuid()` (função nativa do PostgreSQL, ausente no SQLite) | Correção técnica | Bloco SQLite usa `id TEXT PRIMARY KEY` com geração de UUID em Dart (`package:uuid`), documentado explicitamente | **Corrigido** |
| 5 | RLS habilitado apenas para `projects`; `project_dna`, `messages`, `documents` sem isolamento por usuário | Correção técnica / Segurança | Políticas de RLS adicionadas para as 3 tabelas restantes, via subquery contra `projects.user_id` | **Corrigido** |
| 6 | Título "API Guidelines & Supabase Contracts" prometia múltiplos contratos, mas só entregava um | Estrutura | Título agora reflete o conteúdo real; seção 2 cobre os contratos REST prometidos | **Corrigido** |
| 7 | Ausência de contrato de rate limiting para o endpoint de IA (custo/abuso) | Completude | Seção 6 adicionada com limite de 20 req/min por usuário e resposta `429` padronizada | **Corrigido** |
| 8 | Fixtures de teste com timestamps de 2023 num documento "living documentation" v6.1 (2026) | Clareza | Trocados timestamps fixos por `<ISO8601 timestamp>` nos fixtures de `02_Acceptance_Criteria.md` | **Corrigido** |
| 9 | Ausência de indicação sobre onde vive o código-fonte da aplicação | Completude | Adicionada Seção A ("Implementation status") no README do hub | **Corrigido** |
| 10 | `docs.zip` redundante sem indicação de fonte canônica | Estrutura | Adicionada Seção B ("Canonical source note") no README do hub | **Corrigido** |
| 11 | Diagrama de captura de voz sem isolamento de camada UI/worker | Clareza | Separado explicitamente em `03_Product_Flow.md` v1.3 | **Corrigido** |

## Notas sobre a meta de nota 10/10

Uma nota 10/10 segundo os critérios desta auditoria exige impossibilidade de encontrar qualquer melhoria adicional — um padrão propositalmente quase inatingível. As correções acima elevam **API Guidelines** e **Database Schema** de um nível "insuficiente/aceitável" (5/10) para um nível "bom a muito bom" nos critérios de completude e correção técnica, mas nota 10 real exigiria adicionalmente:
1. Verificação cruzada automatizada (CI) confirmando que o DDL documentado corresponde ao schema efetivamente migrado no Supabase e no Drift.
2. Testes de integração que validem os contratos REST e o schema de eventos SSE descritos.
3. Auditoria dos ~40 arquivos restantes do repositório com o mesmo rigor aplicado aqui.

Sem essas três camadas, a nota máxima defensável para o conjunto de documentos revisados é 8-9/10 mesmo após as correções — não 10, por princípio da própria escala usada na auditoria original.
