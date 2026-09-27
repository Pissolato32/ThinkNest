# ThinkNest — Estado da Sincronização Supabase

**Status:** P1.2 — Sync Engine implementado e validado; integração remota autenticada pronta para uso.

## Arquitetura atual

```text
Drift
  ↓
Persistent Sync Outbox
  ↓
Sync Engine
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

## Implementado

1. Adapter Supabase para push/upsert/delete.
2. Injeção do `user_id` autenticado no Project.
3. Consumo FIFO do outbox.
4. Retry com backoff exponencial curto e registro de falhas.
5. Pull incremental por timestamp + ID.
6. Idempotência por upsert e cursores persistentes.
7. Last-write-wins para entidades mutáveis.
8. Semântica imutável para snapshots e mensagens.
9. Remoção do outbox somente após confirmação remota.
10. Aplicação local sem re-enfileirar mudanças remotas.
11. Testes automatizados de push, retry, pull e cursor.

## Pendências posteriores

1. Autenticação/UI completa para criação e gerenciamento da conta.
2. Execução automática em reconexão/background.
3. Observabilidade de sincronização em produção.
4. Testes end-to-end contra um usuário autenticado real.

## Critério de conclusão P1.2

P1.2 está concluído quando o Sync Engine executa o ciclo:

`local mutation → outbox → push → remote confirmation → outbox removal → pull → local merge`

com idempotência, retry, cursores incrementais e resolução de conflitos definidos e testados.
