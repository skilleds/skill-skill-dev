---
description: schematize-skill-dev — scaffold completo de uma skill nova do catálogo, já passando no gate (anatomia, comandos, herdados, teste).
argument-hint: "<slug> <prefixo-de-comando>"
---

# /skill-new — a skill nasce completa e verde

Alvo: `skill-<slug>/` (argumentos: `${ARGUMENTS}` = slug e prefixo de comando). Leia antes
`references/anatomia.md` e `references/description-e-comandos.md` e abra UMA skill madura de domínio
do catálogo como molde (a mais recente de disciplina).

1. **Confira colisão:** `ls -d skill-<slug>`; `grep -l '' skill-*/assets/commands/<prefixo>-*.md` deve
   vir vazio. O prefixo é único no catálogo. Não passou, pare e escolha outro.
2. **Escopo e divisa primeiro:** escreva em duas linhas o que a skill é, o gatilho (que artefato ou
   pedido a ativa) e com quais skills faz divisa. Sem divisa clara, ela vai brigar com uma irmã.
3. **Crie a árvore:** `SKILL.md`, `skill.toml` (`status = "beta"`, `order` livre e conferido nos
   outros `skill.toml`), `VERSION` (`0.1.0`), `CHANGELOG.md` (entrada 0.1.0 com o PORQUÊ),
   `README.md`, `LICENSE` (o mesmo das irmãs), `install.sh` (copie de uma irmã e troque o nome),
   `assets/CLAUDE.md`, `assets/commands/<prefixo>-{help,load,claude,handoff,cc}.md` + 3 a 5 de
   trabalho, `references/` com `stack-versoes.md`, `scripts/` e `versions/v0.1.0/`.
4. **Blocos herdados:** coloque os marcadores no `SKILL.md` e no `assets/CLAUDE.md` e rode o sync
   (`references/herdados.md`). Nunca copie o texto herdado à mão.
5. **Gate executável com vermelho:** pelo menos um `scripts/check-<algo>.sh` que pega violação REAL do
   piso da skill, com `check-<algo>.test.sh` (casos vermelhos e verdes plantados). Veja o vermelho
   falhar antes de ver o verde passar.
6. **Prove:** `bash .claude/skills/schematize-skill-dev/scripts/check-skill.sh skill-<slug>`,
   `node tools/lint.mjs` (zero achados NA skill) e os `*.test.sh`. Diga o que não rodou.
7. **Snapshot da 1ª versão:** `versions/v0.1.0/` (use `scripts/bump-skill.sh` ou o release). A 1ª publicação é nativa: `node tools/release.mjs <slug> 0.1.0 --first` aceita `VERSION` == versão pedida e cria o repo remoto; nunca use `VERSION` 0.0.0 + `.gitkeep` como atalho.
8. **Pisos 22–29 (herdados):** a skill nasce com repo git próprio, `origin` e `HEAD == origin` (piso 22); script sem `scp`/`rsync` de deploy (23); template de CI só `workflow_dispatch` + tags `hml-*`/`v*` + `concurrency` (27, regra `ci-gatilho`); `[descriptions]` pt/en/es; relatório 30 min/handoff 6 h no archive (26); agents terminados encerrados (25). O bloco "Herda os pisos 22–29" vai no `SKILL.md` e no `assets/CLAUDE.md`.
9. Publicação é `/skill-release` (em lote, pelo orquestrador); integração no catálogo (`graph-meta.json`, `skills.json`) está em
   `references/integracao-catalogo.md`.
