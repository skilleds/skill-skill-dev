---
description: schematize-skill-dev — sobe a versão de uma skill nos 4 lugares, grava o snapshot e cobra a entrada do CHANGELOG.
argument-hint: "<diretório-da-skill> <nova-versão X.Y.Z>"
---

# /skill-bump — quatro lugares, uma versão

Argumentos: `${ARGUMENTS}`. No catálogo, o bump de verdade é do `tools/release.mjs` (veja
`/skill-release`); este comando é para a 1ª versão, para repo isolado e para ensaiar.

1. **Escolha a versão** pelo efeito para quem já instalou: correção sem mudar contrato = patch;
   piso/comando/gate novo = minor; quebra de contrato (comando removido, prefixo trocado) = major.
2. **Escreva antes a entrada do CHANGELOG.md** no topo (`## [X.Y.Z] — AAAA-MM-DD`) com o **porquê**,
   não só o quê. O bump recusa sem ela.
3. **Ensaie:** `bash .claude/skills/schematize-skill-dev/scripts/bump-skill.sh <dir> <ver> --dry-run`.
4. **Bumpe:** o mesmo comando sem `--dry-run` altera `VERSION`, `current_version` do `skill.toml`,
   `metadata.version` do frontmatter e a linha `**Versão:**`, e copia o snapshot para
   `versions/v<ver>/`.
5. **Confirme:** `bash .claude/skills/schematize-skill-dev/scripts/check-skill.sh <dir>` deve passar.
6. O quinto lugar (`skills.json` do front) é derivado: `references/integracao-catalogo.md`.
