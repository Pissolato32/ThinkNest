# ThinkNest — Plano de Implementação

**Status:** EXECUÇÃO P0  
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
- [ ] Configurar análise estática e testes.
- [ ] Corrigir documentação legada que ainda referencia React Native/WatermelonDB/Jest/Detox/RxJS.
- [ ] Garantir que `flutter analyze` e `flutter test` possam rodar.

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
- [ ] Home com campo de captura imediato.
- [ ] Criar projeto local em um único envio.
- [ ] Não bloquear captura por autenticação/sync/IA.
- [ ] Estados Captured/Exploring.

**Saída:** ideia → projeto local em poucos segundos.

### P0.4 — Conversation + PAL
- [ ] Contrato provider-neutral.
- [ ] Primeiro adapter.
- [ ] AI Gateway.
- [ ] Context assembler baseado em DNA + últimas mensagens.
- [ ] Fila local quando offline.
- [ ] Streaming quando online.

**Saída:** conversa real preservando o projeto como contexto.

### P0.5 — DNA Engine
- [ ] Extração de fatos.
- [ ] decisões, ambiguidades, restrições e riscos.
- [ ] merge/deduplicação.
- [ ] confidence gate.
- [ ] sugestão/aprovação humana.
- [ ] snapshot após mutação.

**Saída:** conversa gera conhecimento estruturado, não apenas histórico.

### P0.6 — Documents
- [ ] PRD.
- [ ] Architecture.
- [ ] lifecycle Draft → Generated → User Reviewed → Approved → Archived.
- [ ] versões imutáveis.

**Saída:** documentação derivada do DNA.

### P0.7 — Readiness
- [ ] Avaliação multidimensional.
- [ ] blockers.
- [ ] warnings.
- [ ] recomendações.
- [ ] estados NOT_READY / READY_WITH_WARNINGS / READY / BLOCKED.

**Saída:** readiness representa risco/estrutura real, não apenas contagem de cinco campos.

### P0.8 — Implementation Pack
- [ ] manifest.
- [ ] PROJECT_DNA.json.
- [ ] documentos.
- [ ] decisões.
- [ ] prompts.
- [ ] hashes.
- [ ] export local ZIP.

**Saída:** artefato consumível por ferramentas de execução.

## P1 — Plataforma
- Supabase/Auth.
- sincronização.
- fila persistente de AI tasks.
- voz.
- segurança avançada.
- observabilidade.
- CI/CD.

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
