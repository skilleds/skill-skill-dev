# schematize-skill-dev — autoria e manutenção de skills do catálogo

> **Uma skill é um pacote de software distribuído a terceiros.** Esta skill dá a anatomia, o gate, o
> bump e o empacotador para criar e manter skills no padrão da casa: description com gatilho, blocos
> herdados, teste com vermelho plantado, release com snapshot, zip e tag.

Pacote de **skill normativa para [Claude Code](https://claude.com/claude-code)**.
Parte do catálogo **schematize skills**.

## Por que ela existe

O conhecimento de como fazer uma skill estava espalhado em `tools/` do catálogo (lint, release, sync
de herdados, grafo) e na cabeça de quem já publicou. Cada skill nova reintroduzia os mesmos defeitos:
versão em 3 de 4 lugares, description estourada, script sem teste, comando colidindo com o de outra
skill. O lint do catálogo acusava, mas tarde. Aqui o gate fica na mão de quem escreve.

## Instalar

### Pelo app schematize (recomendado)

```bash
schematize install skill-dev    # requer o CLI schematize instalado
```

### Manual

```bash
git clone https://github.com/skilleds/skill-skill-dev.git /tmp/skill-skill-dev
bash /tmp/skill-skill-dev/install.sh .        # instala em .claude/ do projeto atual
```

## O que tem dentro

- **SKILL.md** — o contrato: 14 pisos inegociáveis, a fronteira com `docs` e `engineering` e o mapa de references.
- **references/** — `anatomia`, `description-e-comandos`, `herdados`, `lint-e-testes`, `release`,
  `integracao-catalogo` e `stack-versoes` (anexo volátil com data, fonte e o que foi executado).
- **scripts/** — `check-skill.sh` (o gate de uma skill, sem node nem catálogo), `bump-skill.sh`
  (4 lugares + snapshot) e `pack-skill.sh` (zip com top-level `schematize-<slug>/`), cada um com
  seu `*.test.sh` de casos vermelhos e verdes plantados.
- **assets/** — `commands/` e `CLAUDE.md` sempre-on.

## Comandos

| Comando | O que faz |
|---|---|
| `/skill-help` | lista os comandos |
| `/skill-load` | carrega à força o corpo normativo |
| `/skill-new` | scaffold completo de skill nova, já verde no gate |
| `/skill-review` | audita uma skill: gate, lint e leitura humana |
| `/skill-bump` | sobe a versão nos 4 lugares e grava o snapshot |
| `/skill-release` | o rito de release até o GitHub Release |
| `/skill-claude` | `CLAUDE.md` sempre-on de autoria |
| `/skill-cc` · `/skill-handoff` | context compact / handoff |

## Verificação

```bash
bash scripts/check-skill.test.sh     # vermelho primeiro do gate
bash scripts/bump-skill.test.sh
bash scripts/pack-skill.test.sh
bash scripts/check-skill.sh .        # a skill passa no próprio gate
```

## Licença

MIT. Ver `LICENSE` (inclui avisos de marcas de terceiros).
