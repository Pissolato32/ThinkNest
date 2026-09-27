# ThinkNest — Estado da Sincronização Supabase

**Status:** P1.2 — fundação local de sincronização concluída; Sync Engine ainda pendente.

## Arquitetura atual

```text
Drift
  ↓
Persistent Sync Outbox
  ↓
[próxima etapa: Sync Engine]
  ├── push incremental
  ├── pull incremental
  ├── idempotency
  └── conflict resolution
        ↓
Supabase
```

## Entidades cobertas pelo outbox

Todas as entidades atualmente previstas para sincronização possuem integração local:

- Project
- Project DNA
- Project Snapshot
- Document
- Conversation Message
- AI Task

Cada mutação persistida relevante gera uma entrada `SyncOutboxEntry` contendo entidade, ID, operação, payload JSON, timestamp, tentativas e último erro.

## Semântica

- `upsert` é usado para entidades mutáveis ou eventos persistidos que precisam ser enviados ao remoto.
- `delete` é usado atualmente para exclusão de Project.
- Documents mantêm versionamento imutável; alterações de lifecycle geram um novo evento `upsert` com o estado completo.
- Conversation Messages são persistidos como eventos/mensagens individuais.
- AI Tasks geram eventos para enqueue e mudança de estado.
- O outbox é local e durável; não implica que o remoto já tenha recebido a mudança.

## Supabase

A fundação remota P1.2 possui tabelas para Projects, Project DNA, Project Snapshots, Documents, Conversation Messages e AI Tasks. RLS está habilitado nas tabelas e as políticas vinculam acesso autenticado ao `projects.user_id`.

A aplicação Flutter não deve conter service-role key. Credenciais públicas devem continuar sendo fornecidas por configuração de runtime (`--dart-define`).

## O que ainda falta

1. Adapter Supabase para operações de push.
2. Mapeamento de identidade autenticada para `projects.user_id`.
3. Consumo FIFO do outbox.
4. Retry/backoff e registro de falhas.
5. Pull incremental remoto.
6. Idempotência.
7. Estratégia de conflitos por entidade.
8. Marcação/removal das entradas do outbox somente após confirmação remota.
9. Testes de sincronização usando o projeto Supabase real e/ou contratos mockados.

## Critério para concluir P1.2

P1.2 só estará completamente concluído quando o Sync Engine executar o ciclo:

`local mutation → outbox → push → remote confirmation → outbox removal → pull → local merge`

com idempotência, retry e resolução de conflitos definidos e testados.
