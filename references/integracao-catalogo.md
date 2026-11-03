# Integração no catálogo

> Parte da `schematize-skill-dev`. Uma skill publicada ainda não está "no catálogo": falta o grafo, a
> entrada do front e a instalação. Esta etapa é do dono do catálogo; quem cria a skill entrega a
> proposta pronta.

## 1. O catálogo

Repositório privado `schematizeme/schematize_skills`: contém `tools/` (lint, release, sync de
herdados, grafo, `skills.json`), o índice/grafo gerado e uma cópia de cada `skill-<slug>/` ao lado
(cada uma é repo git independente, ignorado pelo repo do catálogo). Skill nova nasce como repo próprio;
o catálogo a enxerga por estar na mesma pasta.

## 2. `tools/graph-meta.json`

Metadado do grafo §39, uma entrada por skill:

```json
"ordem": [ ..., "<slug>" ],
"skills": {
  "<slug>": {
    "papel": "uma frase: o que a skill faz e a restrição que a define",
    "camada": "ferramenta | disciplina | linguagem | base",
    "stack": "Skill/Markdown + Bash",
    "onde": "GitHub release"
  }
}
```

`ordem` define a ordem das listas geradas. A entrada é **proposta** pelo autor da skill no relatório
final; o dono do catálogo aplica e roda `node tools/build-graph.mjs` (gera índice e grafos; `--check`
confere sincronia). Sem entrada, o grafo mostra "(sem papel declarado)".

O grafo enumera **toda unidade chamável**: cada comando (`assets/commands`) e cada função declarada
nos scripts. Doc-comment acima da função alimenta a descrição; escreva um `# O que: ...` curto.

## 3. `skills.json` do front

O site lê a lista de skills de `content/skills.json` do repositório do front. É derivado dos
`skill.toml`: `node tools/sync-skills-json.mjs` regrava; `--check` confere (o `ci.sh` roda). A
variável `SCHEMATIZE_SKILLS_JSON` aponta o arquivo; sem ela o tool usa um fallback local declarado em
voz alta. Skill nova exige o commit desse arquivo no front (e o deploy do front é gated; não é do
autor da skill).

`skill.toml` alimenta o site: `tag` (rótulo do card), `href` (rota) e as três descrições
(`pt`, `en`, `es`). Escreva as três; `es` e `en` sem `pt` quebram o card.

## 4. `order`

Número livre que ordena o card no site. Confira os `order` existentes (`grep '^order' skill-*/skill.toml`)
e use o próximo livre; ordem repetida não quebra, mas desordena o card.

## 5. Instalação

| Quem | Como |
|---|---|
| Usuário final | app schematize: `schematize install <slug>` (baixa o zip do GitHub Release) |
| Manual | `git clone https://github.com/skilleds/skill-<slug>.git` e `bash install.sh <projeto>` |
| Global na máquina | `bash skill-<slug>/install.sh "$HOME"` (instala em `~/.claude/`) |

`install.sh` é idempotente e poda comando removido. O app mantém as skills atualizadas pela versão do
GitHub Release; por isso o zip tem de ter o layout certo (`references/anatomia.md`).

## 6. O que a skill nova entrega no relatório

1. A árvore criada e os comandos.
2. A saída resumida do gate, dos `*.test.sh` e do lint (zero achados NA skill).
3. URL do repo e do release.
4. A entrada proposta para `tools/graph-meta.json`.
5. As divisas declaradas e **o que precisa mudar em OUTRA skill** para virar ponteiro para esta (o
   orquestrador faz; a skill nova não edita skill alheia).
6. O que não foi verificado.

## 7. Tornar outra skill ponteiro

Quando uma regra passa a ter dona nova, a antiga vira ponteiro: a skill antiga troca o texto por
`schematize-<nova> -> arquivo` e mantém só a linha de fronteira. Isso é um release (minor) da skill
antiga, com o porquê no CHANGELOG. A skill nova não faz essa edição.
