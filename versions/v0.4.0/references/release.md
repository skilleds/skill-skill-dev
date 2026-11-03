# Release de uma skill

> Parte da `schematize-skill-dev`. O release é um rito com ordem: gate, bump, snapshot, CHANGELOG,
> zip, git, GitHub Release, derivados. Pular um passo reintroduz o defeito que o passo evita.

## 1. Os lugares da versão

| # | Lugar | Quem grava |
|---|---|---|
| 1 | `VERSION` | release / `scripts/bump-skill.sh` |
| 2 | `current_version` do `skill.toml` | idem |
| 3 | `metadata.version` do frontmatter do `SKILL.md` | idem |
| 4 | linha `**Versão:** ... vX.Y.Z` do `SKILL.md` | idem |
| 5 | `skills.json` do front | derivado dos `skill.toml` (`tools/sync-skills-json.mjs`) |

Mais: `versions/v<ver>/` (snapshot) e a primeira entrada do `CHANGELOG.md` (escrita por gente, com o
porquê, ANTES do release: o release recusa sem ela e não inventa texto).

## 2. No catálogo: `tools/release.mjs` é o ÚNICO caminho

Dentro do catálogo, **não faça nenhum passo à mão** (nem "só o zip", nem "só a tag"): a ferramenta
valida, é idempotente e publica os derivados. O rito manual da seção 3 é fallback para fora dele.

```bash
node tools/release.mjs <slug> <versão> --dry-run        # ensaio: pré-valida, não grava
node tools/release.mjs <slug> <versão> [--notes "..."]
node tools/release.mjs --batch <slug>@<ver> <slug>@<ver> ...   # gate uma vez, publica em série
# --no-push-derived: pula o commit/push de skills.json e grafos (só se pedirem)
```

Ordem interna (para no primeiro erro):

1. **Pré-condições:** versão SemVer e MAIOR que a atual; 1ª entrada do CHANGELOG igual à versão;
   árvore da skill **limpa**; branch `main`; `main` sincronizada com `origin` (nem commit local sem
   push, nem remoto à frente).
2. **Gate:** `tools/ci.sh` — a fonte da verdade do que ele roda é o próprio script (hoje: self-tests do lint e do índice, gatilhos de CI do piso 27, resiliência do 28, higiene/build-host do 29, deploy/diff dos 22-24, herdados em sincronia, `skills.json`, lint); não enumere aqui. `--skip-gate`
   é dívida declarada, não atalho.
3. **Bump** nos 4 lugares.
4. **Snapshot** `versions/v<ver>/` (`SKILL.md`, `VERSION`, `skill.toml`, `references`, `assets`,
   `scripts`, `gui.json`).
5. **Zip** `skill-<slug>.zip`, top-level `schematize-<slug>/` (acrescenta `CHANGELOG.md` e `LICENSE`).
6. **Git:** `git add` de **lista explícita** (`VERSION`, `skill.toml`, `SKILL.md`, `versions/v<ver>`,
   `CHANGELOG.md`; nunca `-A`), commit `release: v<ver>`, tag anotada `v<ver>`, `push --follow-tags`.
   Fluxo git geral (commit, PR, tag fora de release de skill): `schematize-git`.
   Trailer `Co-Authored-By` em TODO commit da ferramenta (release, derivados, pré-gate): default em
   `tools/release.config.json` (`coauthor`), `RELEASE_COAUTHOR` sobrepõe, vazia ou `--no-coauthor` desliga.
   Antes do gate, o release regenera os grafos e commita só eles (`chore(grafos): regenera antes do
   release <lote>`; `--dry-run` apenas avisa) — não é mais preciso regenerar à mão.
7. **GitHub Release** com o zip; se a release já existe, só regrava o asset (`--clobber`). O zip é
   apagado num `finally`.
8. **Derivados:** `sync-skills-json` e `build-graph` (o grafo carrega a versão de cada skill; sem
   regerar, o release SEGUINTE falha no gate por causa deste).
9. **Publica os derivados:** commit só de `content/skills.json` no front
   (`chore(skills): versões do lote ...`) e de `.schematize/grafos/` no catálogo
   (`chore(grafos): versões do lote ...`), com push e `pull --rebase` se recusado; idempotente.
10. **Gate final:** `tools/ci.sh` de novo; o rc é reportado (rc != 0 -> exit 1).

Retomada: tag já no remoto não é recriada; "nada novo a commitar" segue adiante. Lote interrompido
reporta publicadas e faltantes, sem desfazer.

### Primeira versão dentro do catálogo (nativo, sem hack)

Skill sem nenhuma tag `v*` (local ou no origin) é detectada como 1ª versão: o release aceita a
versão **igual** à `VERSION` atual (ex.: `0.1.0`), cria `skilleds/skill-<slug>` público se
`gh repo view` falhar e empurra com `-u origin main --follow-tags`. Basta o repo git próprio com
commit inicial, árvore limpa e a entrada do CHANGELOG no topo:

```bash
node tools/release.mjs <slug> 0.1.0 --first --notes "..."   # --first: reprova se já houver release
```

Não crie `VERSION` 0.0.0 nem `versions/v0.0.0/.gitkeep` para contornar: era o hack antigo.
Critério e teste: seção "Primeira versão" do RELEASE.md do catálogo.

### O processo REAL: release em lote, feito pelo orquestrador

Na prática o catálogo não publica skill por skill no meio do trabalho: edita-se muitas skills (em
paralelo, por grupos de agents) e **uma única passada** publica o lote. A divisão de trabalho:

1. **Os agents de grupo** só editam a skill e commitam/pushan (commit pequeno por tema, `main`, na
   hora; piso 22). Eles **NÃO** fazem bump, snapshot, tag, zip nem `gh release`, e **não tocam em
   `versions/`**. O que mudou entra numa seção **`## [Não lançado]`** no topo do `CHANGELOG.md` da
   skill (Adicionado / Alterado / Corrigido, com o porquê). `[Não lançado]` não é versão: o gate
   (`changelog-defasado`) e o release ignoram esse cabeçalho.
2. **Herdados:** mudou o piso na base? O orquestrador roda `node tools/sync-herdados.mjs --write`
   (ou `--root <cópia>` se há trabalho alheio em andamento) e `--check`; blocos e arquivos herdados
   nunca se editam à mão (`references/herdados.md`).
3. **Grafos:** `node tools/build-graph.mjs` (o release já regenera e commita só `.schematize/grafos/`
   antes do gate; `--check` confirma). `skills.json` do front vem do `tools/sync-skills-json.mjs`.
4. **O ORQUESTRADOR faz o lote** (não os agents): para cada skill do lote, renomeia `## [Não
   lançado]` para `## [X.Y.Z] — AAAA-MM-DD` (versão SemVer calculada pelo que mudou: piso novo =
   minor), commita e pusha; confere árvore limpa e `main` sincronizada; então
   `node tools/release.mjs --batch <slug>@<ver> ... --dry-run` e, verde, sem `--dry-run`. O gate
   (`tools/ci.sh`) roda UMA vez, a pré-validação é all-or-nothing, cada skill é publicada em série e
   os derivados (`skills.json` no front, grafos no catálogo) saem commitados e publicados.
5. **Fecha provado (piso 22):** em cada skill publicada, no front e no catálogo,
   `git remote -v` não vazio, `git status` limpo e `HEAD == origin`
   (`schematize-git -> scripts/check-git.sh . --conclusao`). Lote que deixa repo sem push **não conclui**.
6. **Ritmo (piso 26):** lote de dezenas leva minutos (~12 min para 21 releases); durante o trabalho
   o orquestrador grava o relatório de 30 min em `<projeto>_archive/relatorios/` (com o custo do
   período lido de `custos/`) e o handoff de 6 h; agents de grupo terminados são encerrados (piso 25).
7. **CI remoto (piso 27):** nada aqui dispara CI por commit; o gate é local (`tools/ci.sh`). Se a
   skill traz `assets/ci/*.yml`, o gatilho é `workflow_dispatch` + `push: tags ["hml-*", "v*"]` com
   `concurrency` (regra `ci-gatilho` do `check-skill.sh`).

**Organização do remoto:** a constante `ORG` de `tools/release.mjs` e `tools/release-first.mjs` é
`skilleds`, e é a org dos `origin` (`github.com/skilleds/skill-<slug>`); os exemplos desta skill usam
a mesma. Mudar de org é mudar a constante e o `origin` de todas as skills, não um parágrafo.

## 3. Fallback, só FORA do catálogo: primeira versão ou repo isolado

Reproduz os passos 3 a 7 à mão, com os scripts desta skill:

```bash
# na pasta que contém skill-<slug>/
bash scripts/check-skill.sh skill-<slug>                # gate verde antes de tudo
bash scripts/bump-skill.sh skill-<slug> <ver>           # só se a versão muda; na 1ª já nasce 0.1.0
bash scripts/pack-skill.sh skill-<slug> /caminho/fora   # zip fora do repo
cd skill-<slug>
git init -b main                                        # só na 1ª vez
git add -- <lista explícita de arquivos>                # nunca -A
git commit -m "release: v<ver>"
git tag -a v<ver> -m "v<ver>"
gh repo create skilleds/skill-<slug> --public --source . --remote origin --push   # 1ª vez
git push --follow-tags                                  # demais vezes
gh release create v<ver> /caminho/fora/skill-<slug>.zip --title "v<ver>" --notes "<texto>"
```

Na 1ª versão a skill já nasce em `0.1.0` com `versions/v0.1.0/` criado pelo `bump-skill.sh` (ou
copiado à mão com os mesmos itens). Instale e prove: `bash skill-<slug>/install.sh "$HOME"`. **Depois** (o fallback não faz sozinho): peça ao dono do
catálogo `tools/sync-skills-json.mjs`, `tools/build-graph.mjs` e o `tools/lint.mjs`, e confira o piso 22
(`git remote -v`, `status` limpo, `HEAD == origin`).

## 4. Depois do release

- No catálogo, `skills.json` e grafos já saem commitados e publicados pela ferramenta. Resta
  `tools/graph-meta.json` (entrada nova de skill nova), do dono do catálogo
  (`references/integracao-catalogo.md`): quem publica diz o que falta; não edita fora do escopo.
- Skills dependentes: mudou um piso na base? Os blocos herdados das outras skills mudam por sync, e
  cada uma precisa do seu release (minor) para o texto novo chegar a quem instalou.

## 5. Erros comuns

| Sintoma | Causa | Correção |
|---|---|---|
| lint: versão dessincronizada | bump manual esqueceu um lugar | `bump-skill.sh` |
| release recusa: árvore suja | arquivo solto na skill | commitar ou descartar antes; nunca `git add -A` para "limpar" |
| release recusa: origin à frente | outro commit no remoto | `git pull`, refaça o gate |
| gate global falha por causa de OUTRA skill | trabalho alheio em andamento | corrija a causa ou publique depois; não use `--skip-gate` sem registrar |
| zip instala em lugar nenhum | top-level errado | sempre `schematize-<slug>/` (use `pack-skill.sh`) |
| comando morto em quem já instalou | skill removeu comando | o `install.sh` poda; reinstale |
| release sem tag | push sem `--follow-tags` | `git push origin v<ver>` |

## 6. Segredo e permissão

O `gh` usa a credencial do usuário; nada de token em arquivo da skill. Release não carrega segredo:
o zip é público. `schematize-infra -> references/cadeia-suprimentos.md` cobre assinatura e proveniência
de artefato, quando o catálogo decidir assinar releases.
