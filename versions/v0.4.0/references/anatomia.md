# Anatomia de uma skill do catálogo

> Parte da `schematize-skill-dev`. O que existe numa skill, onde mora e quem cobra. O gate
> `scripts/check-skill.sh` verifica tudo o que está marcado como obrigatório.

## 1. Árvore

```
skill-<slug>/                      repo git próprio, branch main, remoto público skill-<slug>
  SKILL.md                         contrato: frontmatter + pisos + fronteira + mapa de references
  skill.toml                       metadado do catálogo (slug, name, tag, status, order, versão, i18n)
  VERSION                          a versão, uma linha, X.Y.Z
  CHANGELOG.md                     uma entrada por versão, com o PORQUÊ
  README.md                        porta de entrada de quem chega pelo GitHub
  LICENSE                          o mesmo das irmãs + avisos de terceiros
  install.sh                       instala em .claude/ (idempotente, poda comando removido)
  .gitignore                       *.zip e .release-tmp/
  assets/
    CLAUDE.md                      piso sempre-on, mesclado no CLAUDE.md do projeto de quem instala
    commands/<p>-*.md              comandos slash, prefixo único
    (ci/, repo-skeleton/, ...)     material de referência que a skill entrega
  references/
    *.md                           o corpo normativo, um assunto por arquivo
    stack-versoes.md               anexo volátil: versão, fonte, data
  scripts/
    check-*.sh  check-*.test.sh    gate e seu teste
  versions/v<ver>/                 snapshot de cada versão publicada (nunca editar)
```

Obrigatório (o gate reprova se faltar): `SKILL.md`, `skill.toml`, `VERSION`, `CHANGELOG.md`,
`README.md`, `LICENSE`, `install.sh`, `assets/CLAUDE.md`, `assets/commands/`, `references/`,
`scripts/` e `versions/v<VERSION>/`.

## 2. Nomes (derivam todos do slug)

| Onde | Forma | Exemplo |
|---|---|---|
| Diretório e repo | `skill-<slug>` | `skill-terraform` |
| `name` no frontmatter | `schematize-<slug>` | `schematize-terraform` |
| `slug` no `skill.toml` | `<slug>` | `terraform` |
| Zip da release | `skill-<slug>.zip` | `skill-terraform.zip` |
| Pasta de topo dentro do zip | `schematize-<slug>/` | `schematize-terraform/` |
| Instalada | `.claude/skills/schematize-<slug>/` | |
| Comandos | `<prefixo>-<verbo>.md` | `tf-plan.md` |

O lint reprova `name != schematize-<diretório sem skill->`. O prefixo de comando é livre, mas único
no catálogo (`references/description-e-comandos.md`).

## 3. `skill.toml`

Subconjunto de TOML (escalar e UMA tabela); o leitor do catálogo é mínimo, então não use arrays,
tabelas aninhadas nem aspas simples.

```toml
slug = "terraform"
name = "schematize-terraform"
tag = "Disciplina · IaC (Terraform/OpenTofu)"      # rótulo curto do card no site
status = "beta"                                      # beta | stable
order = 40                                           # ordem no catálogo; confira os outros skill.toml
current_version = "0.2.0"                            # um dos 4 lugares da versão
href = "/terraform"

[descriptions]                                       # texto do site, nas três línguas
pt = "..."
en = "..."
es = "..."
```

Regras: `status = "stable"` exige major maior ou igual a 1 (estável em 0.x é contradição: o lint
reprova). `beta` é o estado de skill nova. As três descrições do site são marketing (podem ser mais
longas que a `description` do frontmatter, que é para o Claude descobrir a skill).

## 4. `VERSION` e os 4 lugares

A mesma versão em: `VERSION`, `current_version` do `skill.toml`, `metadata.version` do frontmatter do
`SKILL.md` e a linha `**Versão:** skill \`schematize-<slug>\` vX.Y.Z.` (uma só; a segunda é ignorada
pelo release e vira aviso). O quinto lugar é o `skills.json` do front, derivado dos `skill.toml`
(`references/integracao-catalogo.md`). SemVer: correção = patch; piso, comando ou gate novo = minor;
quebra de contrato = major.

## 5. `CHANGELOG.md`

Formato Keep a Changelog. A primeira entrada de versão é a vigente ou a **próxima pendente** (maior
que `VERSION`: quem escreve grava a entrada antes do release). Cada entrada abre com um parágrafo de
**porquê** (o defeito ou a decisão que motivou), depois `### Adicionado` / `### Alterado` /
`### Corrigido` / `### Não verificado`. Entrada sem porquê é lista de commits, não changelog.

## 6. `versions/v<ver>/`

Snapshot imutável de cada versão publicada: `SKILL.md`, `VERSION`, `skill.toml`, `references/`,
`assets/`, `scripts/` e `gui.json` (se existir). O release cria; nunca se edita à mão e nenhuma regra
de ponteiro olha dentro dele. Falta o snapshot da versão vigente: o lint reprova.

## 7. `install.sh`

Copia o corpo da skill para `.claude/skills/schematize-<slug>/` excluindo `.git`, `.github`,
`versions`, `install.sh`, `README.md`, `LICENSE` e `*.zip`; achata `assets/commands/*.md` em
`.claude/commands/`; **poda** comando que a skill removeu (senão o comando morto sobrevive para
sempre em quem já instalou). Idempotente. Parte do `install.sh` de uma irmã; só o nome muda.

## 8. O zip da release

Top-level `schematize-<slug>/` contendo `SKILL.md`, `VERSION`, `skill.toml`, `references/`,
`assets/`, `scripts/`, `gui.json` (se houver), `CHANGELOG.md` e `LICENSE`. Fora: `.git`,
`versions/`, `README.md`, `install.sh`. O zip nunca entra no git (`.gitignore`) nem no pacote.
`scripts/pack-skill.sh` produz exatamente isso.

## 9. `gui.json` (opcional)

Skill pode expor ações como botões no app desktop declarando `gui.json` na raiz. É o único arquivo
opcional que o snapshot e o zip levam; o formato é do app, não desta skill.

## 10. Waiver do gate

`.skill-ok` na raiz da skill, uma linha por dispensa: `<regra> <motivo>`. Sem motivo não vale. O
waiver fica no diff e no `grep`; desligar o gate no CI não.
