# Frontmatter, description e comandos

> Parte da `schematize-skill-dev`. A description é o que faz a skill ser DESCOBERTA; o comando é o
> que a faz ser USADA.

## 1. Frontmatter do `SKILL.md`

```yaml
---
name: schematize-<slug>
metadata:
  version: 0.1.0
description: >-
  <O QUE é>. Use ao <gatilho concreto>. <Divisa>: schematize-<outra>.
---
```

- `name` = `schematize-` + o diretório sem `skill-`. O lint reprova a divergência.
- `description` **sempre em bloco `>-`**: escalar solto quebra o YAML assim que o texto tem `: `.
- `metadata.version` é um dos 4 lugares da versão; o release reescreve.
- Logo abaixo do frontmatter, diretivas de arquivo como `cross-skill:` entram como comentário HTML.

## 2. A description

| Limite | Valor | Quem cobra |
|---|---|---|
| Teto por skill | 190 caracteres | `check-skill.sh` (erro); a soma do catálogo tem teto de 9000 (`tools/lint.mjs`) |
| Soma de todas as skills | teto do catálogo | lint (aviso): acima dele o Claude Code lista skills sem descrição |

Os números vivem em `references/stack-versoes.md` (volátil: o catálogo ajusta o orçamento).

Estrutura em três partes, nesta ordem:

1. **O que é**, em uma frase com o substantivo certo ("Backend em Go", "IaC com OpenTofu e Terraform").
2. **Gatilho concreto:** "Use ao tocar `*.tf`, `.terraform.lock.hcl` ..." ou "Use ao projetar ...".
   Gatilho é artefato (extensão, arquivo, comando) ou pedido (verbo + objeto). Lista de virtudes não é
   gatilho.
3. **Divisa:** termina apontando a vizinha ("Visual: schematize-design.") para o modelo não ativar
   a skill errada.

Veto: reivindicar território alheio (a skill de Go não "pega frontend"); listar pisos (isso é do corpo);
repetir o nome da skill; adjetivo vazio ("completo", "robusto").

Teste mental: dado só o texto da description, quando a skill deve ser ativada e quando NÃO? Se a
resposta da segunda pergunta é "não sei", falta divisa.

## 3. Comandos

Arquivos `assets/commands/<prefixo>-<verbo>.md`, achatados em `.claude/commands/` pelo `install.sh`.

```markdown
---
description: schematize-<slug> — <o que faz, uma frase>
argument-hint: "<argumento>"     # opcional
---
```

**Obrigatórios:** `<p>-help` (mapa), `<p>-load` (carrega à força o corpo normativo), `<p>-claude`
(cria/mescla o `CLAUDE.md` sempre-on), `<p>-handoff` (handoff sem compactar), `<p>-cc` (handoff e
`/compact`). **De trabalho:** de 3 a 5, cada um com um verbo e um resultado verificável (`review`,
`plan`, `new`, `release`).

**Prefixo único no catálogo.** Antes de escolher: `ls skill-*/assets/commands | grep '^<p>-'` deve
vir vazio. Dois prefixos na mesma skill também reprovam. O install poda por prefixo; prefixo
compartilhado apagaria o comando de outra skill.

Cada comando de trabalho: (1) diz o alvo e o argumento; (2) roda a máquina primeiro (o gate);
(3) lista o que a máquina não lê; (4) fecha dizendo o que não rodou. Comando que cita outro comando
usa o nome exato: o lint reprova `/<prefixo>-x` que não existe em nenhum `assets/commands/`.

## 4. Fronteira no corpo

O `SKILL.md` leva uma tabela "Fronteira com as outras skills": assunto, dono, ponteiro. O ponteiro
tem a forma `schematize-<slug> -> arquivo` (referência cruzada sempre prefixada). Sem a tabela, duas
skills disputam o mesmo pedido.

## 5. O que o corpo contém

Tese em um parágrafo; linha `**Versão:**`; bloco de precedência (herdado); fronteira; tabela de
comandos; "Como usar"; mapa de references; **pisos inegociáveis** (lista numerada sob `## Pisos ...`;
o README repete a contagem e o gate confere); regra de mídia quando a skill toca visual; relação com
as outras skills. Formato de documento (ADR, runbook) é da `schematize-docs`.
