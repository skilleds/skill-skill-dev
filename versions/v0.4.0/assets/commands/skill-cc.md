---
description: schematize-skill-dev — context compact: grava o handoff no archive e roda /compact.
---
Antes de compactar, **grave o handoff** em `<projeto>/<projeto>_archive/context/` no par
**context + checklist** do padrão da `schematize-archive` (prefixo `AAAA-MM-DD-<slug>-`), FEITO vs
ABERTO. Inclua: quais skills foram criadas ou mexidas, a versão de cada uma, os achados do
`scripts/check-skill.sh` que ficaram abertos, o que já foi publicado (tag, release) e o que falta
(grafo, `skills.json`, instalação), com o motivo. Nunca inclua token nem segredo. Só então rode `/compact`.
