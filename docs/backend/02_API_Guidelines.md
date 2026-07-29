# ThinkNest API Guidelines & Supabase Contracts

**Version:** 1.2
**Status:** Approved
**Protocols:** Supabase SDK / REST / SSE / Edge Functions
**Changelog:** v1.2 adiciona contratos REST completos para `projects`, `documents`, `messages`, especifica o protocolo SSE do endpoint de streaming e formaliza autenticação e rate limiting. Corrige a v1.1, que documentava apenas um endpoint.

---

## 1. Autenticação

- Todas as chamadas (REST e Edge Functions) exigem `Authorization: Bearer <user_jwt>`.
- O JWT é obtido e renovado automaticamente pelo SDK `supabase_flutter`; nenhuma chamada manual de refresh é necessária no client.
- Requisições sem JWT válido retornam `401 Unauthorized` com o corpo de erro definido na seção 4.

## 2. Contratos REST (PostgREST via Supabase)

Todas as rotas abaixo são geradas automaticamente pelo PostgREST do Supabase a partir do schema em `02_Database_Schema.md` e estão sujeitas às políticas de Row Level Security ali definidas — nenhuma rota expõe dados fora do escopo de `auth.uid()`.

### 2.1 `projects`

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/rest/v1/projects?select=*&order=updated_at.desc` | Lista projetos do usuário autenticado |
| `GET` | `/rest/v1/projects?id=eq.<uuid>` | Detalha um projeto |
| `POST` | `/rest/v1/projects` | Cria projeto (body mínimo: `title`) |
| `PATCH` | `/rest/v1/projects?id=eq.<uuid>` | Atualiza campos (ex.: `maturity_level`, `is_pinned`) |
| `DELETE` | `/rest/v1/projects?id=eq.<uuid>` | Remove projeto (cascade em `project_dna`, `messages`, `documents`) |

### 2.2 `documents`

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/rest/v1/documents?project_id=eq.<uuid>&order=created_at.desc` | Lista documentos de um projeto |
| `POST` | `/rest/v1/documents` | Cria documento (body: `project_id`, `doc_type`, `title`, `content_markdown`) |
| `PATCH` | `/rest/v1/documents?id=eq.<uuid>` | Atualiza conteúdo (incrementa `version` via trigger — ver seção 5) |

### 2.3 `messages`

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/rest/v1/messages?project_id=eq.<uuid>&order=created_at.asc` | Histórico de conversa do projeto |
| `POST` | `/rest/v1/messages` | Persiste mensagem (body: `project_id`, `role`, `content`) |

## 3. Contrato de Streaming (AI Gateway)

- **Endpoint:** `POST /functions/v1/ai-gateway-stream`
- **Protocolo:** Server-Sent Events (`Content-Type: text/event-stream`)
- **Headers de resposta obrigatórios:**
  ```
  Content-Type: text/event-stream
  Cache-Control: no-cache
  Connection: keep-alive
  X-Accel-Buffering: no
  ```
- **Body da requisição:**
  ```json
  {
    "project_id": "uuid",
    "message": "string",
    "specialist_role": "string | null"
  }
  ```
- **Schema dos eventos emitidos:**
  ```
  event: token
  data: {"delta": "string"}

  event: specialist_change
  data: {"active_specialist": "string"}

  event: done
  data: {"message_id": "uuid", "usage": {"input_tokens": 0, "output_tokens": 0}}

  event: error
  data: {"type": "provider_error", "detail": "string", "retryable": true}
  ```
- **Desconexão do cliente:** a Edge Function deve monitorar `request.signal` (aborto do lado do cliente) e encerrar a chamada ao provedor de IA imediatamente para evitar custo de tokens não consumidos.
- **Reconexão:** o client não deve tentar `EventSource` nativo (sem suporte a headers customizados); a reconexão é responsabilidade da camada de app, que reenvia a última mensagem não confirmada (sem `done` recebido) após timeout de 10s.

## 4. Contrato de Erros

Todos os erros (REST e Edge Functions) seguem RFC 7807 (`application/problem+json`):

```json
{
  "type": "https://thinknest.app/errors/offline",
  "title": "Network Unavailable",
  "status": 503,
  "detail": "AI services require internet connection in V1. Local project data remains fully functional.",
  "instance": "/functions/v1/ai-gateway-stream"
}
```

Tipos de erro normativos:

| `type` | `status` | Quando ocorre |
|---|---|---|
| `.../errors/offline` | 503 | Sem conectividade ao chamar `ai-gateway-stream` |
| `.../errors/unauthorized` | 401 | JWT ausente ou expirado |
| `.../errors/rate-limited` | 429 | Limite de requisições ao provedor de IA excedido (ver seção 6) |
| `.../errors/validation` | 422 | Corpo da requisição não passa nas constraints do schema |

## 5. Versionamento otimista de documentos

O campo `documents.version` é incrementado via trigger de banco (não pelo client) a cada `UPDATE` bem-sucedido, para evitar sobrescrita silenciosa em edição concorrente. Ver `02_Database_Schema.md` seção 3.

## 6. Rate Limiting

- `ai-gateway-stream`: máximo de 20 requisições/minuto por `user_id`, aplicado na Edge Function via contagem em `Deno KV` com janela deslizante.
- Excedente retorna `429` com o corpo de erro da seção 4 e header `Retry-After: <segundos>`.
