# Piso de autoria de skills (schematize-skill-dev) — sempre-on

Skill é pacote de software distribuído a terceiros: versão, gate e release valem como em qualquer produto.

1. **Um repo por skill:** diretório `skill-<slug>`, `name: schematize-<slug>`, repo público `skill-<slug>`. Prefixo de comando único no catálogo.
2. **Anatomia completa:** `SKILL.md`, `skill.toml`, `VERSION`, `CHANGELOG.md`, `README.md`, `LICENSE`, `install.sh`, `assets/CLAUDE.md`, `assets/commands/`, `references/`, `scripts/`, `versions/v<ver>/`.
3. **Description** em bloco `>-`, no máximo **190 caracteres** (soma do catálogo ≤ 9000), começa pelo que é, tem gatilho concreto ("Use ao tocar ...") e termina na divisa ("X: schematize-Y").
4. **Versão igual nos 4 lugares** (`VERSION`, `skill.toml`, `metadata.version`, linha `**Versão:**`) + `skills.json` do front; `CHANGELOG.md` com o PORQUÊ no topo; snapshot `versions/`.
5. **Bloco herdado nunca se edita à mão:** muda na fonte (`schematize-engineering`) e roda o sync.
6. **Todo script tem `*.test.sh` com caso vermelho E verde**, visto falhar antes de passar.
7. **Fato volátil só no anexo `stack-versoes.md`** com fonte e data; sem prova, `<!-- reverificar -->`.
8. **Referência cruzada prefixada** (`schematize-<slug> -> arquivo`); sem número de seção/ADR que o leitor não lê; sem caminho privado da máquina.
9. **Release:** gate verde, árvore limpa, `git add` com lista explícita (nunca `-A`), tag anotada, zip top-level `schematize-<slug>/`. GitHub é a fonte da verdade: commit e push na hora (`HEAD == origin`, piso 22). Em lote: agents só escrevem `## [Não lançado]` no CHANGELOG; o orquestrador fecha a versão e roda `tools/release.mjs --batch`.
10. **Template de CI** (`assets/ci/*.yml`): `workflow_dispatch` + `push: tags [hml-*, v*]` + `concurrency`; nunca `pull_request`/push em branch (piso 27). `[descriptions]` pt/en/es no `skill.toml`.
11. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

12. Herda os pisos 22–29 da `schematize-engineering` (git como trava de conclusão, deploy só do git, ops é o gate da IA, sem agents inúteis, relatório 30 min/handoff 6 h, CI remoto só antes do hml, microserviço autônomo, build em dev/hml + higiene).

Mídia: imagem/visual gerado nunca por modelo Claude; detecte Codex/Gemini e pergunte qual usar.

Gate: `bash .claude/skills/schematize-skill-dev/scripts/check-skill.sh skill-<slug>` — waiver rastreável em `.skill-ok` (`<regra> <motivo>`).
