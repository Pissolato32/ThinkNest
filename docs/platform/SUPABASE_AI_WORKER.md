# ThinkNest — Cloud AI Task Worker

**Status:** P1.3 — worker cloud + execução periódica preparada.

## Componentes

- `process-ai-task`: executa uma AI Task individual. Chamadas do aplicativo usam o JWT do usuário; chamadas internas usam a chave secreta do worker.
- `process-ai-queue`: drena até 10 tasks `PENDING` por execução usando o cliente administrativo do Supabase, sem expor essa credencial ao Flutter.
- `_shared/ai_task.ts`: contém o claim concorrente, carregamento de contexto, chamada OpenAI-compatible, persistência da resposta e transições de estado.

O claim continua sendo atômico: a task só passa de `PENDING` para `RUNNING` se ainda estiver pendente e abaixo do limite de tentativas. Isso permite que várias execuções concorrentes disputem a fila sem processar a mesma task duas vezes.

## Segredos

Configure no ambiente das Edge Functions:

- `THINKNEST_AI_BASE_URL`
- `THINKNEST_AI_API_KEY`
- `THINKNEST_AI_MODEL` (opcional)
- `THINKNEST_AI_WORKER_SECRET` — segredo exclusivo para cron/worker; nunca coloque no Flutter.

O worker usa `SUPABASE_SERVICE_ROLE_KEY` somente no ambiente server-side da Edge Function. Essa chave nunca deve ser enviada ao aplicativo.

## Agendamento

O Supabase Cron pode invocar uma Edge Function periodicamente via `pg_net`. A configuração do cron é deliberadamente operacional, e não uma migration que grava URLs/chaves de produção no repositório.

Exemplo no SQL Editor, substituindo os valores pelos segredos configurados no projeto:

```sql
select cron.schedule(
  'thinknest-ai-task-worker',
  '* * * * *',
  $$
    select net.http_post(
      url := 'https://<project-ref>.supabase.co/functions/v1/process-ai-queue',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'apikey', '<THINKNEST_AI_WORKER_SECRET>'
      ),
      body := '{}'::jsonb
    ) as request_id;
  $$
);
```

O cron deve executar no máximo conforme a capacidade do provedor de IA e do plano Supabase. O endpoint processa até 10 tasks por disparo.

## Verificação

Antes de considerar o worker operacional:

1. Fazer deploy das duas Edge Functions.
2. Configurar os segredos.
3. Criar uma AI Task `PENDING` autenticada.
4. Confirmar que o cron/worker a leva para `RUNNING` e depois `COMPLETED`.
5. Confirmar a criação da mensagem `ai-task-<task_id>`.
6. Repetir com concorrência para confirmar que uma task não é executada duas vezes.

O CI do repositório deve validar sintaxe/tipos das Edge Functions; a validação end-to-end depende de um projeto Supabase configurado e de um provedor de IA real.
