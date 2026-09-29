# ThinkNest — CI/CD e Deployment

**Version:** 2.1  
**Status:** Approved  
**Stack:** Flutter/Dart + Supabase  
**Objetivo:** definir o caminho de validação, build e promoção do ThinkNest sem pressupor serviços de release que ainda não foram configurados.

---

## 1. Princípios

O pipeline deve:

- manter o quality gate existente como barreira obrigatória;
- usar versões determinísticas de Flutter e Deno;
- separar validação de código, build e publicação;
- não armazenar segredos no repositório;
- não publicar automaticamente uma versão de produção sem os requisitos de assinatura, credenciais e aprovação correspondentes;
- preservar o funcionamento offline-first do aplicativo.

A implementação atual possui CI de Flutter e CI das Edge Functions. O deploy de produção ainda é uma etapa P1.6 a implementar.

## 2. Estado atual

### Flutter CI

O workflow `.github/workflows/flutter.yml` atualmente:

1. faz checkout;
2. fixa Flutter 3.38.0;
3. gera a scaffolding de Android/iOS/Web necessária ao repositório;
4. configura permissões de voz;
5. executa `flutter pub get`;
6. gera código Drift;
7. verifica formatação;
8. executa `flutter analyze`;
9. executa `flutter test`;
10. preserva diagnósticos quando há falha.

O CI é um quality gate. Uma execução vermelha bloqueia a progressão da etapa.

### Supabase Deploy

O workflow `.github/workflows/supabase-deploy.yml` implementa o primeiro passo operacional de P1.6:

- execução exclusivamente manual via `workflow_dispatch`;
- GitHub Environment `production`;
- secrets obrigatórios `SUPABASE_ACCESS_TOKEN`, `SUPABASE_DB_PASSWORD` e `SUPABASE_PROJECT_ID`;
- aplicação das migrations pendentes com `supabase db push`;
- deploy das Edge Functions;
- listagem final das funções implantadas;
- concorrência sem cancelamento, evitando duas promoções simultâneas.

A promoção continua sob controle humano até existir um ambiente staging separado.

### Supabase CI

O workflow `.github/workflows/supabase.yml` atualmente:

1. instala Deno 2.1.x;
2. formata as Edge Functions;
3. executa type-check em `process-ai-task` e `process-ai-queue`.

As Edge Functions estão implantadas no projeto Supabase atual, mas o repositório ainda não possui promoção automática entre ambientes.

## 3. Arquitetura de ambientes

A promoção deve ser progressiva:

`local → CI → staging/preview → production`

### Local

- desenvolvimento e testes do Flutter;
- Supabase local ou ambiente de desenvolvimento quando necessário;
- segredos somente por mecanismos locais apropriados;
- nenhum segredo persistido no Git.

### CI

- validação determinística em pull requests e `main`;
- nenhum segredo de produção necessário para os quality gates básicos;
- builds não assinados podem ser usados para validar empacotamento.

### Staging/Preview

Deve reproduzir, tanto quanto possível, os contratos de produção:

- autenticação;
- RLS;
- migrations;
- Edge Functions;
- AI Task Queue;
- voz/STT;
- observabilidade.

Credenciais de staging devem ser distintas das de produção.

### Production

A publicação deve exigir:

- artefato validado;
- credenciais de publicação;
- assinatura Android/iOS configurada;
- configuração de secrets do Supabase;
- aprovação explícita para promoção.

## 4. Flutter release

O projeto é Flutter. Não utilizar como pressupostos de implementação:

- React Native;
- Expo Updates;
- CodePush;
- Fastlane Match;
- provisioning/certificados armazenados em repositório Git;
- publicação automática em lojas sem credenciais e assinatura configuradas.

Quando o release pipeline for implementado, ele deverá separar:

- build Android;
- build iOS;
- assinatura;
- publicação;
- versionamento/tag.

Até que esses componentes estejam configurados, o CI não deve declarar que uma release foi publicada.

## 5. Supabase release

As migrations e Edge Functions devem ser tratadas como artefatos versionados.

A futura automação deve:

1. validar migrations e Edge Functions no pull request;
2. executar deploy em staging/preview;
3. executar verificações pós-deploy;
4. promover para production somente após aprovação;
5. registrar a versão promovida.

O projeto Supabase atual já possui `process-ai-task` e `process-ai-queue` ativos. Isso não significa que o repositório possua promoção automática configurada.

## 6. Segredos

Segredos de produção não devem aparecer em:

- código-fonte;
- arquivos de configuração versionados;
- logs;
- artefatos de CI.

Os valores reais devem permanecer no mecanismo de secrets apropriado para cada ambiente.

Para o ThinkNest, a política operacional detalhada está em `docs/security/03_Environment_Policy.md`.

## 7. Gates de promoção

Uma promoção deve falhar se qualquer gate obrigatório estiver vermelho:

- Flutter format;
- Flutter analyze;
- Flutter test;
- Drift generation;
- Edge Function format/type-check;
- migrations/estrutura Supabase, quando aplicável;
- verificações de segurança;
- verificações pós-deploy do ambiente de destino.

Falha de uma etapa deve interromper a promoção. Não corrigir o pipeline removendo o gate.

## 8. Estratégia de implementação do P1.6

A ordem recomendada é:

1. alinhar documentação e contratos de ambiente;
2. manter PR/main quality gates;
3. adicionar validação de build sem assinatura;
4. definir staging/preview;
5. automatizar deploy Supabase de forma controlada;
6. adicionar promoção para production;
7. configurar builds assinados e publicação nas lojas;
8. adicionar verificações pós-deploy e rollback operacional.

Itens que dependem de credenciais, certificados, stores ou secrets reais permanecem explicitamente como configuração operacional, não como código fictício.

## 9. Relação com NFRs

Os números em `docs/deployment/02_Non_Functional_Requirements.md` são metas de qualidade. Não devem ser apresentados como métricas medidas até que exista instrumentação e uma execução de benchmark documentada.
