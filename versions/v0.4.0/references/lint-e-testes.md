# Lint do catálogo, gate local e testes

> Parte da `schematize-skill-dev`. O que cobra o lint do catálogo, o que cobra o gate local e como
> se escreve o teste que prova que o gate sabe reprovar.

## 1. Dois gates, dois alcances

| Gate | Onde | Alcance |
|---|---|---|
| `scripts/check-skill.sh <dir>` | esta skill, qualquer máquina | uma skill; só bash/awk; sem node, sem o catálogo |
| `node tools/lint.mjs [--skill <slug>]` | catálogo (privado) | cruza skills: ponteiros, comandos, soma de descriptions, `skills.json` |
| `bash tools/ci.sh` | catálogo | a fonte da verdade é o próprio script (lint, índice, herdados, `skills.json` e os gates dos pisos 22-29: `check-ci-triggers`, `check-resilience`, `check-deploy-git`, higiene/build-host) |

O gate local é a primeira linha (barata, na hora de escrever); o lint e o `ci.sh` são a segunda e
rodam antes de todo release.

## 2. Regras do lint (ids estáveis)

| Id | O que reprova |
|---|---|
| `ref-file` | arquivo `.md` citado em backtick não existe na skill (nem em irmã nomeada perto) |
| `ref-secao` | `§N` que não resolve para heading real |
| `item-por-numero` | anti-padrão citado por número de item (cite por título) |
| `ref-comando` | `/<prefixo>-<nome>` que não existe em nenhum `assets/commands/` |
| `ref-skill` | `schematize-<x>` citada que não existe no catálogo |
| `yaml-valido` | frontmatter inválido ou `name` diferente de `schematize-<dir>` |
| `description` | acima do teto do lint (erro); soma acima do orçamento de 9000 (aviso). O gate local é mais estrito: 190 |
| `versao` | 4 lugares diferentes, CHANGELOG atrás de `VERSION`, falta `versions/v<VERSION>/`, ausência no `skills.json` |
| `deriva-scripts` | cópias de script compartilhado divergentes entre skills |
| `ci-gatilho` (só no `check-skill.sh`) | `assets/ci/*.yml` com `pull_request`/push em branch/`workflow_run`/`schedule`, ou sem `workflow_dispatch` e `concurrency` com `cancel-in-progress` (piso 27) |
| `i18n-ausente` (só no `check-skill.sh`) | `[descriptions]` do `skill.toml` sem `pt`, `en` ou `es` não vazio |
| `ci-pin` | `uses:` em `assets/ci/*.yml` sem SHA de 40 hex (ou `docker://` sem digest) |
| `maturidade` | `stable` em 0.x e afins |
| `contagem` | README diz N pisos, SKILL.md tem outro N (`--fix` corrige o número) |
| `higiene` | byte NUL, tag órfã de geração, `*.zip` no pacote, emoji em `references/` |
| `seta-ascii` | seta unicode em grafo ou índice lido por parser ASCII |
| `anexo-volatil` | versão de terceiro fixada no corpo normativo, ou anexo sem `Verificado em` |

`ref-file` é o que mais pega: citar em backtick o nome de um arquivo de outra skill sem a irmã nomeada por perto, ou com um nome
que não existe. Cite sempre `schematize-<slug> -> arquivo`, ou declare no topo do arquivo
`<!-- cross-skill: nome.md -> schematize-<slug> -->` (verificado: o arquivo tem de existir lá).

## 3. Regras do gate local

`estrutura-arquivo` · `frontmatter` · `description-teto` · `description-gatilho` · `versao-ausente` ·
`versao-dessincronizada` · `versao-linha-multipla` · `changelog-defasado` · `snapshot-ausente` ·
`comando-prefixo` · `comando-obrigatorio` · `comando-frontmatter` · `comando-colisao` ·
`script-sem-teste` · `teste-sem-vermelho` · `teste-sem-verde` · `herdado-ausente` ·
`herdado-desbalanceado` · `anexo-volatil` · `emoji` · `zip-no-pacote` · `ci-pin` ·
`readme-contagem` · `caminho-privado`. Saída `arquivo:linha: [ERRO|AVISO regra] mensagem`; exit
0 passa, 1 reprova, 2 nada para verificar. Waiver: `.skill-ok` (`<regra> <motivo>`).

Dispensa de teste para biblioteca sourceada: `lib.sh` e `*.lib.sh` são isentos; outro nome precisa de `# teste-ok: <motivo>` nas 30 primeiras linhas.
Prefixo de comando = o do `<prefixo>-help.md` e pode ter hífen (`overdev-context-*`); menos de 3 comandos de trabalho é AVISO (help/load/claude/handoff/cc faltando continua erro). Na engineering, o help do catálogo inteiro (`schematize-engineering → assets/commands/schematize-help.md`) é aceito.

## 4. Teste com vermelho plantado

Regra da casa: **todo script tem `*.test.sh`**, e o teste tem caso **vermelho** (defeito plantado que
o script TEM de reprovar) e **verde** (caso limpo que ele TEM de aprovar). Só verde prova que o gate
não trava; só vermelho prova que ele reprova tudo. Os dois, ou é decoração.

Ordem de trabalho (vermelho primeiro):

1. Escreva o caso vermelho para o defeito real do piso da skill.
2. Rode o teste e **veja falhar** (o gate ainda não pega, ou o script nem existe).
3. Implemente a regra até o vermelho passar a ser pego.
4. Escreva o verde e confirme que o gate aprova o limpo.
5. Mutação: estrague a regra de propósito e veja o teste vermelho reclamar. Se nada reclama, o
   teste não testa.

Harness padrão (copie do `scripts/check-skill.test.sh`):

- um diretório temporário (`mktemp -d`) com `trap 'rm -rf "${TMP:?}"' EXIT INT TERM`;
- uma fixture boa (`skill_boa`) e cada caso muta UMA coisa;
- `esperar <exit> <agulha>` confere o código de saída E um trecho da mensagem (exit certo pelo motivo
  errado é falso verde);
- `set -u` sem `-e`, com `EXCEÇÃO DECLARADA` no cabeçalho (o harness precisa seguir após um vermelho);
- contador final e `exit` diferente de zero se houve falha.

## 5. Gate que acha o que existe de verdade

Um gate decorativo detecta o que ninguém faz. O gate de uma skill pega violação REAL do piso:
antes de publicar, rode-o contra um exemplo ruim de verdade (código antigo do projeto, repo de
terceiro). Ferramenta externa ausente (linter, scanner) vira **aviso explícito**, nunca falso verde;
"nada para verificar" sai com código 2, não 0.

## 6. Piso de shell dos scripts

Os scripts da skill passam no gate de `schematize-shell`: `shellcheck` limpo, strict mode (ou
exceção declarada no cabeçalho), `mktemp` com `trap`, sem `exit 0` incondicional no fim, sem caminho
fixo em `/tmp`. O `ci.sh` do catálogo roda esse gate em todos os `.sh`.
