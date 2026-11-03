---
description: schematize-skill-dev — rito de release de uma skill: gate, bump, snapshot, zip, tag, GitHub Release, grafo e skills.json.
argument-hint: "<slug> <versão X.Y.Z>"
---

# /skill-release — o release é um rito, não um push

Argumentos: `${ARGUMENTS}`. Detalhe e erros comuns em `references/release.md`.

1. **Pré-condições:** CHANGELOG com a entrada da versão no topo (com o porquê); árvore da skill
   limpa; branch `main` sincronizada com `origin`; gate da skill verde
   (`scripts/check-skill.sh`) e testes passando.
2. **No catálogo (existe `tools/release.mjs`): é o ÚNICO caminho, e o lote é do ORQUESTRADOR.** Agent de
   grupo NÃO faz bump/snapshot/release: só escreve `## [Não lançado]` no CHANGELOG e commita; o
   orquestrador troca o cabeçalho por `## [X.Y.Z] — data` e roda o lote (`references/release.md`, "O processo REAL"). Não faça bump, snapshot, zip,
   tag nem `gh release` à mão. Rode `node tools/release.mjs <slug> <versão> --dry-run` e depois
   `node tools/release.mjs <slug> <versão> [--notes "..."]`; lote: `--batch <slug>@<ver> ...`. Ele roda o
   gate, bumpa, grava o snapshot, empacota, commita com lista explícita, cria tag e GitHub Release,
   regenera `skills.json` e grafos, **commita e publica esses derivados sozinho** (front e catálogo) e
   roda o `tools/ci.sh` final; reporte o rc. `--no-push-derived` só se pedirem para não publicar.
3. **Rito manual = fallback, só FORA do catálogo (1ª versão, repo isolado, sem `tools/release.mjs`):**
   `scripts/bump-skill.sh` (4 lugares + snapshot),
   `scripts/pack-skill.sh` (zip com top-level `schematize-<slug>/`), `git add` com lista explícita,
   commit, tag anotada `v<ver>`, `git push --follow-tags` e `gh release create v<ver>
   skill-<slug>.zip`. O zip nunca é commitado.
4. **Instale e prove:** `bash skill-<slug>/install.sh "$HOME"` e confira o comando novo.
5. **Fecha provado (piso 22):** por skill, no front e no catálogo, `git remote -v` não vazio, `status` limpo,
   `HEAD == origin` (`schematize-git -> scripts/check-git.sh . --conclusao`). Sem isso o release não concluiu.
6. **Depois:** no catálogo, `skills.json` e grafos já saem publicados pela ferramenta; só
   `tools/graph-meta.json` (entrada de skill nova) é do dono do catálogo. Fora dele, diga o que falta.
7. Release que falhou no meio retoma sem duplicar: tag existente não é recriada e o asset do release
   é regravado (`--clobber`).
