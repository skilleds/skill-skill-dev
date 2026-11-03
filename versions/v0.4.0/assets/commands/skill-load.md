---
description: schematize-skill-dev — carrega à força TODO o corpo normativo de autoria de skills e passa a aplicá-lo nesta sessão.
---
Carregue **agora** o corpo normativo da skill `schematize-skill-dev`. A partir daqui, nesta sessão,
isto **não é opcional**.

1. **Leia na íntegra, sem trabalhar de memória.** Caminho:
   `.claude/skills/schematize-skill-dev/references/*.md` (projeto) ou
   `~/.claude/skills/schematize-skill-dev/references/*.md` (global):
   - `anatomia.md` — árvore da skill, `skill.toml`, `VERSION`, `CHANGELOG.md`, `versions/`, `install.sh`, zip.
   - `description-e-comandos.md` — frontmatter, teto e alvo da description, gatilho, divisa, prefixo único.
   - `herdados.md` — blocos herdados, variantes, parâmetros, `--check` e `--write`.
   - `lint-e-testes.md` — regras do lint, gate local, teste com vermelho e verde plantados.
   - `release.md` — os 4 lugares, snapshot, zip, tag, `gh release`, 1ª versão, retomada.
   - `integracao-catalogo.md` — `graph-meta.json`, grafo, `skills.json`, `order`, instalação.
   - `stack-versoes.md` — anexo volátil: versões, limites do lint, o que foi executado.
2. **Rode o gate na skill em que está trabalhando** antes de opinar sobre estilo:
   `bash .claude/skills/schematize-skill-dev/scripts/check-skill.sh skill-<slug>`
3. **Aplique daqui em diante** a toda skill que você escrever ou tocar, e diga qual piso está
   aplicando quando ele mudar o que você ia fazer. **Nunca publique** com o gate vermelho nem com
   árvore suja.
