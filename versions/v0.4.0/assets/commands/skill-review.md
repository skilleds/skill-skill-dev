---
description: schematize-skill-dev — audita uma skill contra o piso: roda o gate e o lint do catálogo, depois lê o que a máquina não lê.
argument-hint: "[diretório da skill, ex.: skill-terraform]"
---

# /skill-review — skill é pacote de software

## 1. A máquina primeiro

```bash
bash .claude/skills/schematize-skill-dev/scripts/check-skill.sh "${ARGUMENTS:-.}"
bash "${ARGUMENTS:-.}"/scripts/*.test.sh          # cada teste, os vermelhos e os verdes
node tools/lint.mjs --skill <slug>                # se o catálogo estiver ao lado
```
`0` passa · `1` reprova · `2` **nada para verificar** — que não é aprovação. Ferramenta ausente
(`node`, `shellcheck`), diga qual faltou; não finja verde.

O gate cobre: arquivos obrigatórios, frontmatter, description (teto e gatilho), versão nos 4 lugares,
CHANGELOG e snapshot, comandos (prefixo único, obrigatórios, colisão), script sem teste ou sem caso
vermelho/verde, blocos herdados, anexo volátil, emoji, zip no pacote, caminho privado, CI sem SHA,
contagem de pisos. Waiver: `.skill-ok` com `<regra> <motivo>`.

## 2. Depois, o que a máquina não lê

- **A description faz a skill ser descoberta?** O gatilho é um artefato ou pedido concreto, não uma
  lista de virtudes? A divisa aponta a irmã certa?
- **Território:** a skill reivindica algo que é de outra? A tabela de fronteira cobre o que pode
  confundir?
- **O gate pega violação real** do piso da skill ou é decorativo? Plante um defeito e veja reprovar.
- **Fato volátil** no corpo normativo em vez do anexo? Data de verificação é recente?
- **Referências:** ponteiro prefixado, sem número de seção que o leitor não abre, sem caminho privado.
- **Comandos:** cada um faz uma coisa e diz quando NÃO usar? Os de trabalho cobrem o ciclo?
- **Mídia:** se a skill toca visual, a regra de imagem (Codex/Gemini, pergunta ao usuário) está lá?
- **Português:** acentuação, sem emoji, setas ASCII.

## 3. Feche

Achado vira correção no mesmo PR ou item de checklist com dono. O vermelho do próprio gate:
`bash scripts/check-skill.test.sh`.
