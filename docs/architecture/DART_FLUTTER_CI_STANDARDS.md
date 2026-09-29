# ThinkNest — Padrão Dart/Flutter e Quality Gate

**Status:** Normativo para código novo e manutenção P0/P1

Este documento consolida regras que devem ser aplicadas antes de integrar código Dart/Flutter ao repositório. O objetivo é evitar problemas de formatação, imports, tipos ou diferenças entre o ambiente local e o CI.

## 1. Ferramenta canônica

O CI é a referência final para a qualidade do código. A versão de Flutter atualmente fixada no CI é `3.38.0`.

Executar localmente, na mesma ordem do CI:

```bash
flutter create . --platforms=android,ios,web --no-pub
flutter pub get
dart run build_runner build
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

Se a máquina local não possuir Flutter/Dart, a validação deve ser feita pelo CI antes de considerar a mudança concluída.

## 2. Formatação Dart é uma barreira obrigatória

Não tentar reproduzir manualmente o estilo do formatter. Executar o formatter oficial antes do commit:

```bash
dart format lib test
```

Para verificar sem alterar arquivos:

```bash
dart format --output=none --set-exit-if-changed lib test
```

Se o CI informar que arquivos foram `Changed` ou que `Formatted N files (M changed)`, esses arquivos ainda não estão no formato canônico. Executar o formatter real e commitar o resultado.

## 3. Imports

- Usar imports pelo caminho canônico.
- Após reorganizar diretórios, procurar referências antigas.
- Um tipo deve possuir um local canônico; evitar duplicar modelos para resolver imports.
- Depois de corrigir formatting, deixar o pipeline avançar até `flutter analyze` para revelar imports quebrados e erros de tipos.

## 4. Tipos e sintaxe Dart

- Não usar `|=` para acumular valores `bool`; usar lógica booleana explícita, por exemplo `changed = operation() || changed`.
- Respeitar os tipos exigidos pelas APIs, especialmente wrappers como `Value<T>` do Drift.
- Não usar `const` quando alguma expressão da construção não é constante.
- Após alterações no schema Drift, regenerar o código com `build_runner`.
- Evitar colisões de nomes entre modelos de domínio e classes geradas pelo Drift; usar aliases ou `hide` quando necessário.

## 5. Drift

Sempre que tabelas, companions, colunas ou queries forem alterados:

```bash
dart run build_runner build
flutter analyze
flutter test
```

O código gerado não deve ser editado manualmente. A correção deve ser feita na definição da tabela, companion, query ou configuração de geração.

## 6. Testes

Toda nova regra de domínio/aplicação deve ter teste automatizado.

O mínimo esperado para uma mudança P0 é:
1. teste do comportamento normal;
2. teste dos limites/erros relevantes;
3. teste de persistência quando houver mudança no Drift;
4. teste de UI quando o fluxo visível for alterado.

Um teste não deve ser usado para esconder erro de compilação ou de arquitetura.

## 7. Ordem do CI

O workflow oficial deve manter esta ordem:
1. checkout;
2. Flutter fixado;
3. geração de scaffolding;
4. `flutter pub get`;
5. geração Drift;
6. `dart format --set-exit-if-changed`;
7. `flutter analyze`;
8. `flutter test`;
9. diagnostics apenas em falha.

Essa ordem é deliberada: problemas baratos e determinísticos devem falhar antes de análise e testes.

## 8. Regra de diagnóstico

Quando o CI falhar:
1. capturar o log da etapa que falhou;
2. corrigir a causa;
3. não remover ou enfraquecer o quality gate;
4. executar novamente o mesmo conjunto de verificações;
5. só avançar a fatia depois de CI verde.

Uma falha posterior não deve ser inferida enquanto uma etapa anterior ainda bloqueia o pipeline. Se `dart format` falha, corrigir formatting antes de tratar problemas revelados por `flutter analyze`.

## 9. Checklist antes de integrar

- [ ] `dart format --set-exit-if-changed lib test`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `build_runner` executado quando houver alteração relacionada ao Drift
- [ ] imports revisados após movimentação de arquivos
- [ ] nenhum código gerado editado manualmente
- [ ] novos comportamentos possuem testes
- [ ] documentação e contratos continuam alinhados
- [ ] CI verde antes de avançar para a próxima fatia

## 10. Histórico de falhas e prevenção

As falhas do Flutter CI devem virar regras permanentes, não apenas correções pontuais.

### 10.1 Testes assíncronos em Dart

O método de produção `Future<void>` não pode ser validado como se lançasse exceção de forma síncrona.

Para uma operação que deve falhar:

```dart
await expectLater(
  operation(),
  throwsStateError,
);
```

Porém, **a forma assíncrona correta não torna a expectativa semanticamente correta**. Antes de usar `throwsStateError`, verificar a máquina de estados e confirmar que a transição realmente é inválida.

No P0.6 ocorreu exatamente esta regressão:

- `Generated → User Reviewed` é válida.
- `User Reviewed → Approved` é válida.
- `Approved → Archived` é válida.
- Portanto, esperar `StateError` para `User Reviewed → Approved` estava errado.
- A transição inválida usada pelo teste deve ser uma que o contrato realmente rejeita, como `Approved → Generated`.

O CI run `36261737555` confirmou a causa: 21 testes passaram e apenas o teste de lifecycle falhou porque esperava `StateError` de uma operação que retornava `Future<void>` com sucesso.

**Regra permanente:** todo teste de máquina de estados deve verificar primeiro a tabela/contrato de transições e cobrir pelo menos uma transição válida e uma inválida. Não inferir invalidade pelo nome da operação ou pela intenção do teste.

### 10.2 Formatter

O histórico do P0.6 mostrou repetidas falhas de `dart format` causadas por tentativas de reproduzir manualmente a saída do formatter.

**Regra permanente:** nunca ajustar estilo por inferência. Rodar o formatter oficial e aplicar literalmente sua saída.

### 10.3 Analyze depois do formatter

O CI também revelou problemas que só apareceram depois que o formatter ficou verde: imports ausentes, colisões com tipos gerados pelo Drift, `Value<T>` e construções `const` inválidas.

**Regra permanente:** não corrigir vários estágios ao mesmo tempo. A ordem é formatter → analyze → test; cada estágio deve ficar verde antes de atacar a causa do estágio seguinte.

### 10.4 Drift/build_runner

O Flutter 3.35.7 reportou que `--delete-conflicting-outputs` foi removido e ignorado pelo build_runner.

**Regra permanente:** usar a invocação suportada pelo toolchain fixado no CI:

```bash
dart run build_runner build
```

Não manter flags depreciadas/removidas apenas por hábito.

### 10.5 Diagnóstico obrigatório de testes

O CI agora preserva `flutter-test.log` como artefato quando o pipeline falha. Isso evita depender apenas do resumo visual do Actions para descobrir qual teste falhou.
## 11. Procedimento obrigatório para diagnóstico e correção de CI/CD

Esta seção define o procedimento operacional padrão para qualquer falha de CI/CD. **Nenhuma alteração corretiva deve ser feita antes da análise do log da execução que falhou**, salvo quando a própria mensagem do usuário já fornecer o diagnóstico completo e verificável.

### 11.1 Fluxo padrão

O fluxo obrigatório é:

1. **Identificar a execução**
   - localizar o workflow/run correspondente ao commit ou PR;
   - registrar run ID, commit SHA, status e conclusão;
   - confirmar se a execução é da versão mais recente do branch/PR.

2. **Identificar o primeiro estágio bloqueador**
   - inspecionar os jobs e steps na ordem do workflow;
   - localizar o primeiro step com `failure`;
   - não tratar steps posteriores que foram `skipped` como causas.

3. **Ler o log do estágio que falhou**
   - obter o log completo ou o trecho relevante do step;
   - identificar a mensagem de erro concreta;
   - distinguir erro de código, formatação, dependência, geração, ambiente, infraestrutura ou configuração do CI.

4. **Estabelecer a causa raiz**
   - relacionar a mensagem do CI ao arquivo, linha, comando ou configuração afetada;
   - quando o log apontar um arquivo específico, inspecionar a versão exata desse arquivo no commit que falhou;
   - não substituir diagnóstico por tentativa e erro.

5. **Aplicar a menor correção suficiente**
   - alterar somente o que é necessário para eliminar a causa identificada;
   - preservar comportamento e arquitetura não relacionados;
   - não enfraquecer testes, quality gates ou regras do workflow para obter um CI verde.

6. **Criar nova execução**
   - commitar a correção;
   - confirmar que o novo commit disparou um novo workflow;
   - acompanhar novamente desde o primeiro estágio.

7. **Repetir até verde**
   - se o novo CI falhar, voltar obrigatoriamente ao passo 2;
   - não presumir que a nova falha possui a mesma causa da anterior;
   - somente depois de `format → analyze → test` verdes considerar a fatia validada.

### 11.2 Regra de primeira falha

A **primeira falha determinística na ordem do pipeline é o próximo problema a resolver**.

Exemplo:

- `Generate Drift code`: verde
- `Verify formatting`: vermelho
- `Analyze`: skipped
- `Test`: skipped

O problema a tratar é exclusivamente o formatter. Não se deve alterar código para resolver hipotéticos erros de `analyze` ou `test` antes de fazer o formatter passar.

Outro exemplo:

- `Verify formatting`: verde
- `Analyze`: vermelho
- `Test`: skipped

Nesse caso, o log do `Analyze` deve ser analisado antes de qualquer alteração. Os testes ainda não constituem evidência de uma nova falha.

### 11.3 Classificação do diagnóstico

Antes da alteração, classificar a falha em uma destas categorias:

| Categoria | Exemplos | Ação inicial |
|---|---|---|
| Formatting | `dart format`, arquivos `Changed` | executar formatter oficial |
| Generation | Drift/build_runner | corrigir fonte/configuração e regenerar |
| Dependencies | pub get, resolução de versão | revisar `pubspec`/lock e ambiente CI |
| Analyze/Compile | imports, tipos, APIs, nullability | corrigir código conforme erro reportado |
| Tests | assertion, lifecycle, fixture | analisar teste + contrato da funcionalidade |
| Environment | Flutter/Dart/OS/toolchain | comparar versões e configuração do CI |
| Infrastructure | runner, timeout, serviço externo | verificar se é falha transitória antes de alterar código |
| Workflow | YAML, permissions, secrets, actions | corrigir configuração do pipeline |

### 11.4 Evidência mínima antes de editar

Uma alteração corretiva de CI deve ter, antes do commit:

- [ ] run ID identificado;
- [ ] commit SHA identificado;
- [ ] primeiro step bloqueador identificado;
- [ ] log do step consultado;
- [ ] mensagem/erro concreto identificado;
- [ ] arquivo/configuração afetada identificada quando possível;
- [ ] causa classificada;
- [ ] correção mínima definida.

Se algum desses itens estiver indisponível, a ação padrão é **coletar mais evidência**, não editar por tentativa.

### 11.5 Pós-correção

Depois de uma correção:

1. verificar o diff do commit;
2. confirmar que a alteração corresponde ao diagnóstico;
3. aguardar o novo CI;
4. verificar novamente os steps;
5. se passar, registrar o resultado;
6. se falhar, iniciar um novo diagnóstico independente.

**Não considerar um CI "provavelmente verde" porque a correção parece correta. O estado do workflow é a fonte de verdade.**

### 11.6 Falhas repetidas do mesmo tipo

Quando a mesma categoria de falha ocorre novamente:

- comparar o log novo com o log anterior;
- verificar se é exatamente o mesmo arquivo/comando;
- não assumir que a primeira correção foi aplicada corretamente;
- inspecionar o conteúdo efetivamente presente no novo SHA;
- verificar se o formatter/toolchain utilizado localmente é o mesmo do CI.

Se a mesma falha persistir após uma correção aparentemente adequada, investigar a diferença entre o estado efetivo do repositório e a alteração pretendida antes de realizar uma terceira alteração.

### 11.7 Regra específica para formatter

Quando o CI retornar algo como:

`Changed <arquivo>`

ou

`Formatted N files (M changed)`

a correção padrão é executar **o formatter oficial sobre o arquivo/conjunto afetado**, em vez de tentar reproduzir manualmente a formatação.

Depois, verificar o conteúdo resultante e somente então criar o commit.

### 11.8 Regra específica para logs

O resumo visual do GitHub Actions não substitui o log do step.

Para qualquer falha:

`Workflow → Job → Step → Log → Causa → Correção → Novo Workflow`

Essa cadeia deve ser seguida antes de considerar a falha resolvida.

### 11.9 Critério para avançar

Uma etapa de desenvolvimento somente pode avançar quando:

- o CI da alteração atual estiver concluído;
- `Generate Drift code`, quando aplicável, estiver verde;
- `Verify formatting` estiver verde;
- `Analyze` estiver verde;
- `Test` estiver verde;
- não houver uma falha conhecida ignorada;
- o diff final corresponder ao objetivo da mudança.

**CI verde é requisito de avanço, não apenas uma informação de status.**
