# ThinkNest — Política de Ambientes e Segredos

**Version:** 1.0  
**Status:** Approved  
**Scope:** Flutter client, Supabase, Edge Functions, CI/CD e integrações de IA/STT

## 1. Objetivo

Estabelecer separação de responsabilidades entre cliente, banco, Edge Functions, CI e provedores externos, reduzindo exposição de credenciais e evitando que configurações de desenvolvimento sejam promovidas implicitamente para produção.

## 2. Ambientes

- **Local/desenvolvimento:** desenvolvimento e testes locais; credenciais são fornecidas por configuração local e nunca commitadas.
- **CI:** executa quality gates e testes determinísticos. Não recebe segredos de provedores de IA/STT quando o teste não exige integração real.
- **Supabase/prod:** ambiente operacional. Secrets ficam no ambiente de Edge Functions e não são embutidos no aplicativo Flutter, no repositório ou em artefatos de build.
- **Promoção:** migrations e Edge Functions devem ser promovidas de forma explícita e verificável; CI verde é pré-requisito, mas não substitui validação operacional.

## 3. Classificação de credenciais

### Cliente Flutter

Pode conter apenas configuração pública necessária ao cliente, como URL do Supabase e publishable key. O cliente nunca recebe SUPABASE_SERVICE_ROLE_KEY, chaves privadas de IA/STT ou segredos de worker.

### Edge Functions

Segredos privados incluem, quando utilizados:

- SUPABASE_SERVICE_ROLE_KEY
- THINKNEST_AI_API_KEY
- THINKNEST_STT_API_KEY
- THINKNEST_AI_WORKER_SECRET

Configurações não secretas podem ser mantidas como variáveis de ambiente, incluindo URLs e identificadores de modelo.

## 4. Autenticação e autorização

- Funções expostas ao cliente devem validar a sessão do usuário e aplicar RLS para acesso aos dados.
- Workers internos autenticados por segredo devem validar o segredo antes de executar operações privilegiadas.
- Service-role credentials ficam restritas ao backend/Edge Functions.
- Alterações em permissões, RLS ou funções SECURITY DEFINER exigem revisão e validação de segurança antes da promoção.

## 5. Logs e privacidade

Logs operacionais podem registrar evento, identificador técnico da tarefa, tipo, tentativa e duração. Não devem registrar prompts, transcrições, conteúdo de documentos, payloads completos, tokens ou chaves.

A auditoria persistente registra mutações críticas e metadata mínima, sem copiar conteúdo de conversa ou payloads de AI Tasks.

## 6. Regra de promoção

Uma alteração de segurança, banco ou Edge Function só deve ser considerada promovida quando:

1. o código estiver versionado no GitHub;
2. os quality gates aplicáveis estiverem verdes;
3. migrations estiverem aplicadas no ambiente alvo;
4. Edge Functions necessárias estiverem implantadas;
5. a configuração de secrets necessária estiver presente no ambiente alvo;
6. uma verificação operacional compatível com a mudança tiver sido executada.

## 7. Incidentes de configuração

Segredos não devem ser copiados para issues, PRs, logs ou arquivos versionados. Em caso de exposição, a credencial deve ser revogada/rotacionada no provedor e o incidente registrado sem armazenar o segredo comprometido.
