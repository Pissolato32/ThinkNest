# ThinkNest — Padrão Dart/Flutter e Quality Gate

**Status:** Normativo para código novo e manutenção P0/P1

Este documento consolida regras que devem ser aplicadas antes de integrar código Dart/Flutter ao repositório. O objetivo é evitar problemas de formatação, imports, tipos ou diferenças entre o ambiente local e o CI.

## 1. Ferramenta canônica

O CI é a referência final para a qualidade do código. A versão de Flutter atualmente fixada no CI é `3.35.7`.

Executar localmente, na mesma ordem do CI:

```bash
flutter create . --platforms=android,web --no-pub
flutter pub get
dart run build_runner build --delete-conflicting-outputs
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
dart run build_runner build --delete-conflicting-outputs
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
