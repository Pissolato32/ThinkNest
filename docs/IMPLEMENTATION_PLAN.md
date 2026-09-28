# ThinkNest — Plano de Implementação

**Status:** P0 concluído; P1.1 concluído; P1.2 concluído  
**Issue principal:** #5  
**Fonte normativa:** `docs/`

## Objetivo

Levar o ThinkNest da constituição arquitetural para um produto funcional através de um único vertical slice:

`Capture → Project → Project DNA → Conversation → Documents → Readiness → Implementation Pack`

A implementação deve preservar os princípios da Constituição: offline-first, autoridade humana, isolamento por projeto, Project DNA como fonte de verdade e ausência de geração de código de produção.

## Ordem obrigatória

### P0.1 — Fundação
- [ ] Criar aplicação Flutter/Dart.
- [ ] Configurar Riverpod.
- [ ] Criar estrutura DDD.
- [x] Configurar análise estática e testes.
- [ ] Corrigir documentação legada que ainda referencia React Native/WatermelonDB/Jest/Detox/RxJS.
- [x] Garantir que `flutter analyze` e `flutter test` rodem no GitHub Actions.

**Saída:** aplicativo Flutter mínimo executável.

### P0.2 — Project + Project DNA
- [ ] Entidades de domínio Project e ProjectDNA.
- [ ] Drift como persistência local.
- [ ] Repositories independentes da infraestrutura.
- [ ] UUID e versionamento.
- [ ] Snapshot imutável.
- [ ] Testes unitários.

**Saída:** projeto criado e persistido sem Internet.

### P0.3 — Quick Capture
- [x] Home com campo de captura imediato.
- [x] Criar projeto local em um único envio.
- [x] Não bloquear captura por autenticação/sync/IA.
- [x] Estado inicial Captured; transição para Exploring permanece como próxima evolução de domínio.

**Saída:** ideia → projeto local em poucos segundos.

**Implementado:**
- caso de uso `CreateProject`;
- `DriftProjectRepository` atrás da interface de domínio;
- Project + Project DNA inicial persistidos em transação local;
- Riverpod para injeção de banco/repositório/casos de uso;
- lista reativa de projetos capturados;
- testes de aplicação, persistência Drift e fluxo de UI;
- CI #47 verde com formatação, análise, geração Drift e testes.

### P0.4 — Conversation + PAL
- [x] Contrato provider-neutral.
- [x] Primeiro adapter compatível com API OpenAI (`/chat/completions`).
- [x] AI Gateway mínimo via caso de uso `SendMessage`.
- [x] Context assembler baseado em DNA + mensagens persistidas.
- [x] Fila local durável para falhas/offline, preservando tarefas `PENDING`.
- [x] Streaming SSE no adapter provider-neutral.
- [x] Conversa local integrada à tela do projeto.

**Saída:** conversa real preservando o projeto como contexto, sem acoplamento do domínio a um fornecedor.

### P0.5 — DNA Engine
- [x] Contrato provider-neutral para extração de fatos.
- [x] Extração determinística mínima de fatos explicitamente marcados pelo usuário.
- [x] decisões, ambiguidades, restrições e riscos como inferências estruturadas.
- [x] merge/deduplicação.
- [x] confidence gate: >95% automático, 80–95% sugestão, <80% esclarecimento.
- [x] sugestão/aprovação humana antes de aplicar inferências intermediárias.
- [x] snapshot imutável após mutação do DNA.

**Saída:** conversa pode gerar conhecimento estruturado, não apenas histórico.

**Limite consciente desta fatia:** o extrator inicial é determinístico e provider-neutral; a extração semântica via IA fica desacoplada para a próxima evolução do adapter/orquestrador.

### P0.6 — Documents
- [x] PRD.
- [x] Architecture.
- [x] lifecycle Draft → Generated → User Reviewed → Approved → Archived.
- [x] versões imutáveis.

**Saída:** documentação derivada do DNA.

**Implementado:**
- documentos versionados persistidos localmente;
- lifecycle determinístico com aprovação humana;
- PRD e Architecture derivados da versão exata do DNA;
- visualização e avanço de lifecycle na UI;
- testes de persistência e matriz completa de transições.

### P0.7 — Readiness
- [x] Avaliação multidimensional.
- [x] blockers.
- [x] warnings.
- [x] recomendações.
- [x] estados NOT_READY / READY_WITH_WARNINGS / READY / BLOCKED.

**Saída:** readiness representa risco/estrutura real, não apenas contagem de cinco campos.

**Implementado:**
- evaluator determinístico provider-neutral;
- dimensões de problema, público, proposta de valor, stack, restrições, decisões e documentos;
- blockers para estrutura crítica ausente;
- warnings para lacunas, incertezas, riscos e documentos ainda não aprovados;
- recomendações derivadas dos findings;
- tela de Readiness integrada ao workspace da conversa;
- testes cobrindo NOT_READY, READY_WITH_WARNINGS e READY.

### P0.8 — Implementation Pack
- [x] manifest.
- [x] PROJECT_DNA.json.
- [x] documentos.
- [x] decisões.
- [x] prompts.
- [x] hashes.
- [x] export local ZIP.

**Implementado nesta fatia:**
- caso de uso BuildImplementationPack provider-neutral e determinístico;
- pacote com MANIFEST.json, PROJECT_DNA.json, PRD, Architecture, decisões, prompts e .cursorrules;
- SHA-256 por arquivo;
- archive para geração ZIP inteiramente no cliente;
- share_plus para compartilhar o ZIP pela interface nativa quando suportada;
- export bloqueado até existirem PRD e Architecture aprovados;
- testes do manifesto, hashes, conteúdo do ZIP e bloqueio por lifecycle.

**Saída:** artefato consumível por ferramentas de execução.

## Padrão Dart/Flutter e CI

As regras operacionais de linguagem, formatação, imports, Drift, testes e diagnóstico estão consolidadas em [`docs/architecture/DART_FLUTTER_CI_STANDARDS.md`](architecture/DART_FLUTTER_CI_STANDARDS.md). Esse documento é normativo e deve ser consultado antes de integrar código Dart/Flutter.

A correção deve ser feita na causa, não no quality gate. Em especial, `dart format --set-exit-if-changed lib test` é uma barreira obrigatória e `flutter analyze` só é tratado depois que o formatter passa.

## Quality Gate — obrigatório antes de avançar uma fatia

Nenhuma nova fatia P0 pode ser iniciada enquanto o CI do commit-base não estiver verde.

O pipeline oficial deve, nesta ordem:
1. fixar a versão do Flutter usada no CI;
2. gerar a scaffolding de plataforma necessária ao repositório;
3. instalar dependências com `flutter pub get`;
4. gerar código Drift com `build_runner`;
5. verificar formatação com `dart format --set-exit-if-changed`;
6. executar `flutter analyze`;
7. executar `flutter test`;
8. preservar diagnósticos como artifact somente quando houver falha;
9. cancelar execuções antigas da mesma branch quando houver um commit mais novo.

Regras de implementação:
- não avançar para a próxima etapa após CI vermelho;
- não remover uma barreira do CI apenas para obter build verde;
- corrigir a causa no código/configuração e executar novamente;
- manter versões de ferramentas determinísticas sempre que possível;
- cada nova camada deve entrar acompanhada de testes antes de integrar a próxima camada;
- em falhas de CI, capturar a saída da etapa que falhou antes de fazer novas alterações.

## P1 — Plataforma

### P1.1 — Auth Foundation
- [x] Dependência `supabase_flutter` estável compatível com o baseline Dart.
- [x] Configuração por `SUPABASE_URL` + `SUPABASE_PUBLISHABLE_KEY` via `--dart-define`.
- [x] Inicialização opcional: credenciais ausentes não bloqueiam o modo offline.
- [x] Contrato de domínio `AuthRepository` independente do Supabase.
- [x] Adapter Supabase para sessão, login por e-mail/senha, observação de sessão e logout.
- [x] Testes do contrato provider-neutral.
- [x] Projeto Supabase configurado e schema/RLS/Data API validados.
- [x] Persistência/sincronização de Projects, DNA, Documents e Snapshots.

**Saída:** identidade autenticada pode ser introduzida sem transformar o Supabase na fonte de verdade da UI.

**P1.1 concluído:** projeto Supabase ThinkNest configurado, baseline remoto criada e RLS validado.

### P1.2 — Sincronização
- [x] Modelo de mudanças/outbox.
- [x] Sync queue persistente.
- [x] Integração do outbox com Projects, Project DNA e Snapshots.
- [x] Integração do outbox com Documents, ConversationMessages e AI Tasks.
- [x] RLS remoto habilitado nas tabelas de sincronização e políticas vinculadas ao usuário autenticado.
- [x] Push/pull incremental.
- [x] Idempotência por upsert/cursor e conflito determinístico.

**P1.2 concluído:** o ciclo local `mutation → outbox → push → remote confirmation → pull → local merge` está implementado com retry/backoff, cursores incrementais, last-write-wins para entidades mutáveis e semântica imutável para snapshots/mensagens. O acesso remoto é protegido por RLS e os privilégios do Data API para `authenticated` foram verificados.

**Estado desta etapa:** o Sync Engine executa push/pull incremental, retry/backoff, cursores persistentes e merge local com resolução determinística de conflitos. A validação remota autenticada de ponta a ponta continua como etapa de integração, não como requisito para o núcleo offline-first.

### P1.3 — AI Task Queue Cloud
- [ ] sincronização das AI tasks persistentes.
- [ ] retomada automática após reconexão.
- [ ] estado de execução e falhas observáveis.

### P1.4 — Voz
- [ ] captura local.
- [ ] transcrição imediata.
- [ ] refinamento assíncrono.

### P1.5 — Segurança e observabilidade
- [ ] auditoria.
- [ ] métricas/logs.
- [ ] políticas de segurança e ambientes.

### P1.6 — CI/CD avançado
- [ ] deploy.
- [ ] ambientes.
- [ ] promoção entre ambientes.

- Supabase/Auth.
- sincronização.
- fila persistente de AI tasks.
- voz.
- segurança avançada.
- observabilidade.
- CI/CD avançado (deploy, ambientes e promoção entre ambientes).

## P2 — Expansão
- especialistas avançados;
- plugins;
- Notion/GitHub/Figma/Linear/Slack;
- premium;
- analytics;
- demais export profiles.

## Regra de progresso

Uma etapa só é concluída quando:
1. código existe;
2. testes cobrem o comportamento;
3. documentação está alinhada;
4. o fluxo pode ser demonstrado;
5. não há contrato arquitetural conflitante.

Não adicionar novas funcionalidades P1/P2 para mascarar uma etapa P0 incompleta.
