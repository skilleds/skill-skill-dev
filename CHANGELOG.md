# Changelog — schematize-skill-dev

Todas as mudanças relevantes deste pacote, no formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
com versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [0.4.0] — 2026-11-03
### Adicionado
- Processo de release REAL documentado (`references/release.md`): `tools/release.mjs --batch`, `## [Não lançado]` nos agents, orquestrador fecha a versão, `sync-herdados`, grafos, derivados, piso 22 pós-release, ritmo e custo.
- `check-skill.sh`: regras `ci-gatilho` (template de CI sem `pull_request`/push em branch; exige `workflow_dispatch` e `concurrency` com `cancel-in-progress`, piso 27) e `i18n-ausente` (`[descriptions]` pt/en/es), com testes vermelho e verde.
- Checklist de skill nova herda os pisos 22–29; bloco "Herda os pisos 22–29".
### Corrigido
- Teto de `description` 350/235 -> 190 (padrão real da casa; soma ≤ 9000) no gate, docs e CLAUDE.md, com teste de 190 (passa) e 191 (reprova).
- Org do remoto: docs passam a `skilleds` (a de `tools/release.mjs` e dos `origin`) em vez de `schematizeme`.
- `release.md` e `lint-e-testes.md` não enumeram mais os gates do `ci.sh` (apontam o script como fonte); fallback manual lista o que fazer depois (skills.json, grafos, lint, piso 22).

## [0.3.2] — 2026-10-16
### Alterado
- `references/release.md`: o release regenera e commita os grafos ANTES do gate (`--dry-run` só avisa)
  e o trailer `Co-Authored-By` vale para todos os commits da ferramenta, com default em
  `tools/release.config.json` (`RELEASE_COAUTHOR` sobrepõe; vazia ou `--no-coauthor` desliga).
- Porquê: grafo defasado reprovava o gate (3 vezes num dia) e só o commit `release:` levava coautoria.

## [0.3.1] — 2026-10-15
### Alterado
- `references/release.md` e `/skill-new`: documentam a 1ª versão nativa do `tools/release.mjs`
  (`--first`; aceita versão == `VERSION`, cria o repo remoto público) e vetam o hack
  `VERSION` 0.0.0 + `versions/v0.0.0/.gitkeep`.
- Porquê: skill nova (`regression`) precisou do hack porque o release exigia versão > atual.

## [0.3.0] — 2026-10-15
### Alterado
- `/skill-release` e `references/release.md`: dentro do catálogo, `node tools/release.mjs <slug> <ver>`
  (ou `--batch`) é o ÚNICO caminho; o rito manual vira fallback só fora do catálogo.
- Documenta os passos novos da ferramenta: commit+push automático dos derivados (`skills.json` no front,
  `.schematize/grafos/` no catálogo), `--no-push-derived` e o `ci.sh` final.
- Porquê: agentes seguiam o rito manual e esqueciam os derivados, deixando o GitHub atrás do local.

## [0.2.0] — 2026-10-14
### Alterado
- `check-skill.sh` recalibrado após rodar nas 45 skills: `lib.sh`/`*.lib.sh` isentos de `script-sem-teste`;
  menos de 3 comandos de trabalho vira AVISO (o mínimo segue erro só para help/load/claude/handoff/cc);
  prefixo de comando vem do `<prefixo>-help.md` (aceita hífen, ex.: `overdev-context-*`); `schematize-help.md`
  aceito na engineering. Casos novos (vermelho e verde) em `check-skill.test.sh`.
- `references/release.md` aponta `schematize-git` para o fluxo git geral; description reduzida a ≤190.
- Porquê: o gate gerava falso positivo em skills legítimas e o orçamento de descriptions do catálogo estourou.

## [0.1.0] — 2026-10-14
Primeira versão. O catálogo cresceu para dezenas de skills e o conhecimento de como fazer uma estava
espalhado em `tools/` (lint, release, sync de herdados, grafo) e na cabeça de quem já publicou. Cada
skill nova reintroduzia os mesmos defeitos (versão em 3 de 4 lugares, description estourada, script sem
teste, comando colidindo com o de outra skill) e só o lint do catálogo, tarde, acusava.

### Adicionado
- `SKILL.md` com 13 pisos, fronteira com `schematize-docs` e `schematize-engineering`, mapa de references.
- `references/`: `anatomia`, `description-e-comandos`, `herdados`, `lint-e-testes`, `release`,
  `integracao-catalogo` e `stack-versoes` (anexo volátil com data e fonte).
- `scripts/check-skill.sh` (gate: estrutura, frontmatter, description, versão nos 4 lugares, CHANGELOG,
  snapshot, comandos, script com teste vermelho e verde, herdados, anexo volátil, emoji, zip, caminho
  privado, CI pinado, contagem de pisos) + `check-skill.test.sh` (40 casos); `bump-skill.sh` e
  `pack-skill.sh`, cada um com teste.
- Comandos: `skill-help`, `skill-load`, `skill-new`, `skill-review`, `skill-bump`, `skill-release`,
  `skill-claude`, `skill-handoff`, `skill-cc`.

### Não verificado
- O rito de release foi reproduzido à mão (tag, zip, `gh release`) na 1ª versão; `tools/release.mjs`
  não foi executado por esta skill (ver `references/stack-versoes.md`).
