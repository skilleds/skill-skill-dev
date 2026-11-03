---
description: schematize-skill-dev — gera o handoff (context.md + checklist.md) no archive, sem compactar.
---
Gere o handoff em `<projeto>/<projeto>_archive/context/`: `AAAA-MM-DD-<slug>-context.md` (o que foi
feito, decisões, o que o gate acusou, estado de cada skill: versão, tag, release) e
`AAAA-MM-DD-<slug>-checklist.md` (FEITO vs ABERTO, nas três classes da casa: `- [ ]` máquina ·
`- [H ]` humano · `- [~]` on-hold). Não compacte — só grave. Nunca grave token nem segredo.
