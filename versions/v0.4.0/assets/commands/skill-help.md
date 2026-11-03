---
description: Mapa da skill schematize-skill-dev (criar e manter skills do catálogo: anatomia, versão, gate, release).
---
**schematize-skill-dev** — uma skill é um pacote de software distribuído a terceiros: versão, gate, teste e release.

| Comando | O que faz |
|---|---|
| `/skill-help` | esta lista |
| `/skill-load` | carrega à força TODO o corpo normativo (anatomia, description, herdados, lint e testes, release, catálogo) e passa a aplicá-lo |
| `/skill-new` | scaffold completo de uma skill nova, já passando no gate |
| `/skill-review` | audita uma skill: `scripts/check-skill.sh`, lint do catálogo e leitura do que a máquina não lê |
| `/skill-bump` | sobe a versão nos 4 lugares, grava o snapshot e cobra a entrada do CHANGELOG |
| `/skill-release` | o rito de release até o GitHub Release, grafo e `skills.json` |
| `/skill-claude` | cria ou mescla o `CLAUDE.md` sempre-on de autoria na raiz do repo |
| `/skill-cc` · `/skill-handoff` | context compact / handoff no archive |

Pareia com: `schematize-engineering` (base e fonte dos herdados), `schematize-docs` (formato de doc),
`schematize-shell` (piso dos scripts), `schematize-infra` (CI/CD e supply chain), `schematize-models`
(roteamento de modelos e regra de imagem).
