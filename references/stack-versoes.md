# Anexo volátil — ferramental e limites (autoria de skills)

> Parte da skill **schematize-skill-dev**. **Fonte volátil:** versão de ferramenta, limites do lint e
> SHAs de actions mudam. O corpo normativo diz o **princípio**; o número mora aqui, com data e fonte.
>
> **Verificado em: 2026-10-14.** Cadência: antes de cada release da skill e quando o catálogo
> mudar `tools/`.
> Método: leitura do código de `tools/lint.mjs`, `tools/release.mjs`, `tools/ci.sh`,
> `tools/sync-herdados.mjs`, `tools/build-graph.mjs` no catálogo (commit `351dafa`), versões lidas com
> `--version` na máquina de desenvolvimento e SHAs lidos com `gh api`. Nada aqui veio de memória.

## Limites do catálogo (lidos do código)

| Item | Valor | Fonte |
|---|---|---|
| Teto da `description` por skill | 190 caracteres (erro no `check-skill.sh`) | orçamento do catálogo (soma <= 9000); `tools/lint.mjs` ainda tem 350 como piso mais frouxo |
| Soma das `description` do catálogo | 9000 caracteres (aviso) | `tools/lint.mjs` |
| Itens copiados no snapshot | `SKILL.md`, `VERSION`, `skill.toml`, `references`, `assets`, `scripts`, `gui.json` | `tools/release.mjs` |
| Itens do zip | os do snapshot + `CHANGELOG.md` e `LICENSE`, top-level `schematize-<slug>/` | `tools/release.mjs` |
| `git add` do release | `VERSION`, `skill.toml`, `SKILL.md`, `versions/v<ver>`, `CHANGELOG.md` | `tools/release.mjs` |
| Gates de linguagem no `ci.sh` | swift, kotlin, dart, c, cpp (vermelhos), Python e shell | `tools/ci.sh` |

Se `tools/lint.mjs` mudar o teto, o gate local usa a variável `SKILL_DESC_MAX` (e `SKILL_DESC_ALVO`)
até o `check-skill.sh` ser atualizado.

## Ferramentas na máquina onde a skill foi escrita

| Ferramenta | Versão | Fonte |
|---|---|---|
| Node.js | v24.21.0 | `node --version` |
| GitHub CLI (`gh`) | 2.102.0 (2026-09-30) | `gh --version` |
| GNU bash | 5.2.37 | `bash --version` |
| git | 2.47.3 | `git --version` |
| ShellCheck | 0.11.0 | `shellcheck --version` |
| Info-ZIP zip | 3.0 | `zip -v` |
| js-yaml (vendorizado no lint, MIT) | 4.1.1 | cabeçalho de `tools/vendor/js-yaml.mjs` |

O lint não precisa de `npm ci` (parser YAML vendorizado). `shellcheck` ausente vira aviso no gate de
shell do catálogo, não verde.

## SHAs de actions (para `assets/ci`)

| Action | Tag | SHA | Fonte |
|---|---|---|---|
| `actions/checkout` | v4.2.2 | `11bd71901bbe5b1630ceea73d27597364c9af683` | `gh api repos/actions/checkout/git/ref/tags/v4.2.2` em 2026-10-14 |

Tag é mutável; o lint exige SHA de 40 hex. Para qualquer outra action, leia o SHA com `gh api` na
hora e anote a tag no comentário.

## O que foi executado nesta skill

- `scripts/check-skill.test.sh` (40 casos), `bump-skill.test.sh` (12) e `pack-skill.test.sh` (12):
  vermelhos e verdes, rodados em 2026-10-14.
- O gate rodado em skills reais do catálogo (`skill-terraform`, `skill-docker` passam; skills mais
  antigas reprovam nas regras novas, como esperado).
- `node tools/lint.mjs --skill skill-dev`: só o achado esperado de skill nova ausente do `skills.json` (5º lugar, do dono do catálogo); `check-shell.sh` do catálogo sem erro nos `.sh`.
- Não executado: `tools/release.mjs` (o gate global pode estar vermelho por trabalho de outras
  skills); o release da 1ª versão foi reproduzido à mão.

## Não verificado

- Política de assinatura de release/tag do catálogo (se haverá `cosign`/commits assinados):
  <!-- reverificar -->.
- Comportamento do app `schematize install` com skill nova antes de entrar no `skills.json`:
  <!-- reverificar -->.
