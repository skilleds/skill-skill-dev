---
name: schematize-skill-dev
metadata:
  version: 0.4.0
description: >-
  Cria e mantém skills do catálogo: anatomia, description, herdados, lint, teste com vermelho, release e grafo. Use ao tocar skill-*/, SKILL.md ou skill.toml. Docs: schematize-docs.
---
<!-- cross-skill: precedencia.md, orquestracao.md -> schematize-engineering -->

# Autoria e manutenção de skills (schematize-skill-dev)

Disciplina normativa para **fazer e manter uma skill do catálogo**. A tese: **uma skill é um pacote
de software distribuído a terceiros** — tem versão, gate, teste e release como qualquer produto. Skill
publicada sem gate reintroduz a cada versão os mesmos defeitos (versão em 3 de 4 lugares, description
estourada, script sem teste, comando que colide com o de outra skill), e o catálogo só acusa tarde,
no lint global. Esta skill põe o gate na mão de quem está escrevendo.

**Versão:** skill `schematize-skill-dev` v0.4.0. Changelog em `CHANGELOG.md`.

## Precedência e herança (leia antes de divergir)

<!-- herdado:engineering/precedencia:dominio intro="Esta skill é o recorte **autoria e manutenção de skills do catálogo** das disciplinas de **domínio** (não de linguagem): a skill como artefato de software — empacotamento, versão, gate e release. Ferramenta de quem mantém o catálogo, nunca serviço de produto." cmd="skill" -->Esta skill é o recorte **autoria e manutenção de skills do catálogo** das disciplinas de **domínio** (não de linguagem): a skill como artefato de software — empacotamento, versão, gate e release. Ferramenta de quem mantém o catálogo, nunca serviço de produto.

1. **Onde esta skill divergir da base, a BASE MANDA.** Aqui mora a especialização do domínio ou da
   ferramenta — o como, o padrão, o gate. Divergência de *piso* é defeito desta skill, não variante local.
2. **O que não está repetido aqui é HERDADO, não dispensado.** Esta skill herda os pisos da base e
   os comandos dela cobrem o **domínio**, não o piso geral. Valem integralmente, sem cópia local:
   - **§28 Archive** — `<projeto>/<projeto>_archive/` é **repositório git próprio, PRIVADO e
     obrigatório**, criticidade 0 (`schematize-archive`).
   - **§35 Definition of Done** e a lista de anti-padrões (citada por **título**, nunca por número).
   - **§39 Índice/MAPA** — enumeração exaustiva (uma entrada por unidade chamável, `M == N`) e grafo
     com arestas em ASCII (`A -> B`), nunca a seta unicode.
   - **IAM** (`schematize-engineering` → `references/iam.md`): identidade ≠ email, ≥2 fatores, ReBAC
     multi-tenant, argon2id-only para senha nova, sessão longa e logout irreversível.
   - **Efeito externo** nunca sai de não-produção (`schematize-engineering` →
     `references/efeitos-externos.md`).
   - **Orquestração** (`schematize-engineering` → `references/orquestracao.md` §9): o principal não
     desenvolve (é Claude Opus); executor mais barato que resolve — `haiku`/`sonnet` → Codex Terra → Cursor → `opus` só após falha; visual direto ao Codex; imagem nunca pelo Claude: detecta Codex/Gemini e pergunta ao usuário qual usar (Codex é a sugestão, não automática), nunca API paga.
3. **QA, ops, IAM e índice não têm comando próprio aqui:** vêm da base `/eng-*`. Para trabalho
   contínuo use `/eng-overdev`; para planejar `/eng-plan`; para varrer a base `/eng-scan`; para
   revisão geral `/eng-review` (e `/eng-ops`, `/eng-iam`, `/eng-index`). Os comandos
   `/skill-*` cobrem o domínio desta skill; o piso geral é o da base.<!-- /herdado -->

## Fronteira com as outras skills

| Assunto | Dono | Ponteiro |
|---|---|---|
| **Anatomia, versão, description, herdados, lint, testes, release, grafo e instalação de uma skill** | **esta skill** | `references/*.md` abaixo |
| Formato de documento (ADR, runbook, README, OpenAPI, diagramas) e o que o texto de uma skill deve conter como doc | `schematize-docs` | `schematize-docs -> SKILL.md`; aqui só o contêiner (onde o arquivo mora e o que o gate cobra) |
| Base normativa: DoD, archive, IAM, efeito externo, orquestração, rol de linguagens; é também a FONTE dos blocos herdados | `schematize-engineering` | `schematize-engineering -> references/orquestracao.md`, `assets/herdados/` |
| Roteamento a Codex/Gemini/Cursor e regra de imagem | `schematize-models` | `schematize-models -> SKILL.md` |
| Piso de shell dos scripts da skill | `schematize-shell` | `schematize-shell -> references/piso.md` |
| Pipeline de CI/CD e supply chain do repo da skill | `schematize-infra` | `schematize-infra -> references/entrega.md` |
| Handoff e archive do projeto | `schematize-archive` | `schematize-archive -> SKILL.md` |

## Comandos (Claude Code)

| Comando | O que faz |
|---|---|
| `/skill-help` | lista os comandos |
| `/skill-load` | carrega à força o corpo normativo (anatomia, description, herdados, lint e testes, release, catálogo) |
| `/skill-new` | scaffold completo de uma skill nova, já passando no gate |
| `/skill-review` | audita uma skill contra o piso: gate, lint do catálogo e leitura do que a máquina não lê |
| `/skill-bump` | sobe a versão nos 4 lugares, grava o snapshot e cobra a entrada do CHANGELOG |
| `/skill-release` | o rito de release (gate, bump, snapshot, zip, tag, GitHub Release, grafo, skills.json) |
| `/skill-claude` | cria/mescla o `CLAUDE.md` sempre-on de autoria na raiz do repo |
| `/skill-cc` · `/skill-handoff` | context compact / handoff arquivado |

## Como usar

1. **Rode o gate antes de discutir estilo:** `bash scripts/check-skill.sh skill-<slug>` — `0` passa ·
   `1` reprova · `2` **nada para verificar** (que não é aprovação). Funciona sem node e sem o catálogo.
2. **Anatomia primeiro** (`references/anatomia.md`): arquivos, `skill.toml`, `VERSION`, `CHANGELOG.md`,
   `versions/`, `install.sh`, layout do zip.
3. **Description e comandos** (`references/description-e-comandos.md`): o que cabe no orçamento de
   listagem e como o gatilho é escrito.
4. **Herdados** (`references/herdados.md`): blocos que vêm da base e nunca se editam à mão.
5. **Lint e testes** (`references/lint-e-testes.md`): o que o lint do catálogo cobra e como se escreve
   teste com vermelho plantado.
6. **Release** (`references/release.md`) e **integração** (`references/integracao-catalogo.md`):
   bump, snapshot, zip, tag, grafo, `skills.json`, instalação.

Mapa de references:

| Tarefa | Reference |
|---|---|
| Árvore da skill, `skill.toml`, `VERSION`, `CHANGELOG.md`, `versions/`, `install.sh`, o que entra no zip | `references/anatomia.md` |
| Frontmatter, description (teto, alvo, gatilho, divisa), nomes de comando e prefixo único, comandos obrigatórios | `references/description-e-comandos.md` |
| Blocos herdados, variantes e parâmetros, arquivos herdados, `--check` e `--write`, o que nunca fazer | `references/herdados.md` |
| Regras do lint do catálogo, gate local, teste com vermelho e verde, harness, waiver | `references/lint-e-testes.md` |
| Os 4 lugares + `skills.json`, CHANGELOG, snapshot, zip, tag, `gh release`, 1ª versão, retomada, erros comuns | `references/release.md` |
| `graph-meta.json`, grafo/índice, `skills.json` do front, `skill.toml` i18n, `order`, instalação e app | `references/integracao-catalogo.md` |
| Versões de ferramenta, limites do lint, SHAs, o que foi executado (anexo volátil) | `references/stack-versoes.md` |

Scripts: `scripts/check-skill.sh` (gate) · `scripts/bump-skill.sh` (4 lugares + snapshot) ·
`scripts/pack-skill.sh` (zip com top-level `schematize-<slug>/`); cada um com seu `*.test.sh`.

## Pisos inegociáveis (vetam o atalho)

1. **Um repo por skill:** diretório `skill-<slug>`, `name: schematize-<slug>`, repo público
   `skill-<slug>`. O prefixo dos comandos é **único** no catálogo.
2. **Anatomia completa:** `SKILL.md`, `skill.toml`, `VERSION`, `CHANGELOG.md`, `README.md`, `LICENSE`,
   `install.sh`, `assets/CLAUDE.md`, `assets/commands/`, `references/`, `scripts/` e `versions/v<ver>/`.
   Nada de `*.zip` dentro do pacote.
3. **Description em bloco `>-`**, no máximo **190 caracteres** (a soma do catálogo tem teto de 9000;
   `check-skill.sh` reprova acima de 190), começando pelo **que é**, com **gatilho concreto** ("Use ao
   tocar ...") e terminando na **divisa** ("X: schematize-Y"). Nunca reivindica território alheio.
4. **Versão igual nos 4 lugares** (`VERSION`, `current_version` do `skill.toml`, `metadata.version` do
   frontmatter, linha `**Versão:**` única) mais o `skills.json` do front. O `CHANGELOG.md` abre com a
   versão vigente (ou a próxima pendente) e explica o **porquê**. `versions/v<ver>/` existe.
5. **Bloco herdado nunca se edita à mão:** a fonte é `schematize-engineering` (`assets/herdados/`);
   muda lá e roda o sync. Toda skill de domínio leva os blocos de precedência e de orquestração.
6. **Todo script tem `*.test.sh` com caso vermelho E verde**, e o vermelho foi **visto falhar** antes
   de passar. Gate que não sabe reprovar é decoração.
7. **Fato volátil só em `references/stack-versoes.md`**, com fonte e `Verificado em: AAAA-MM-DD`;
   sem prova, `<!-- reverificar -->`. Versão de terceiro no corpo normativo é defeito.
8. **Comandos:** `<p>-help`, `<p>-load`, `<p>-claude`, `<p>-handoff`, `<p>-cc` mais 3 a 5 de trabalho,
   todos com `description` no frontmatter; nenhum nome repetido em outra skill.
9. **Referência cruzada sempre prefixada** (`schematize-<slug> -> arquivo`); sem número de seção ou
   de ADR que o leitor não consegue abrir; **sem caminho privado da máquina** (nem home, nem repo
   privado citado como se o leitor o tivesse).
10. **Português com acentuação correta, sem emoji, setas ASCII** (`->`) nos artefatos lidos por parser.
11. **Release só com gate verde, árvore limpa e `main` sincronizada, em lote pelo orquestrador:** agents de grupo só escrevem `## [Não lançado]` no CHANGELOG e commitam; o orquestrador fecha a versão e roda `tools/release.mjs --batch` (`references/release.md`); `git add` com lista explícita
    (nunca `-A`), tag anotada `v<ver>`, zip com top-level `schematize-<slug>/`, `gh release` com o zip,
    e depois grafo e `skills.json` regenerados.
12. **GitHub é a fonte da verdade:** commit e push na hora; nada de versão local que o remoto não tem.
13. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

14. **Template de CI da skill** (`assets/ci/*.yml`) nasce com `workflow_dispatch` + `push: tags ["hml-*", "v*"]` e `concurrency` com `cancel-in-progress` (piso 27); `pull_request`/push em branch é vetado e `check-skill.sh` reprova (`ci-gatilho`). `skill.toml` traz `[descriptions]` pt/en/es não vazias (`i18n-ausente`).
<!-- herdado:engineering/pisos-22-29:bloco -->**Herda os pisos 22–29 da `schematize-engineering`** (texto completo em `assets/CLAUDE.md` dela): 22 tudo no git — sem remote, push falho ou HEAD≠origin a demanda NÃO se conclui; 23 deploy só do git (VETADO scp/rsync/tar|ssh/docker save|load/git bundle); 24 o ops é o gate da IA — a IA nunca muda a VPS direto nem escreve SQL, só operação nomeada (`ssh vps "ops <op>"`); 25 sem agents inúteis (entregou, morreu); 26 relatório a cada 30 min e handoff a cada 6 h; 27 CI remoto só antes do hml, a pedido ou em tag (`workflow_dispatch` + `hml-*`/`v*`; VETADO `pull_request`, `push` em branch, `workflow_run`, cron sem justificativa); 28 microserviço autônomo (fila durável + 7 testes de resiliência); 29 build/teste na máquina dev/hml quando existe (ponte só no workspace de build, nunca prd) + higiene (`scripts/higiene.sh`).<!-- /herdado -->

## Regra de mídia

Skill que toca visual (capa, ícone, imagem de README) nunca gera mídia por modelo Claude: detecte
Codex e Gemini disponíveis e **pergunte ao usuário qual usar**. Nenhum disponível: avise sem rodeio
que visual gerado pelo Claude tem qualidade inversamente proporcional à de código (sai ruim de
verdade) e ofereça alternativas — instalar Codex ou Gemini, imagem de banco com licença comercial,
ou asset do cliente. Claude é o melhor em código.

## Relação com as outras skills

- **`schematize-engineering`** — a base e a fonte dos blocos herdados; o que muda no piso muda lá.
- **`schematize-docs`** — o formato de ADR, runbook e README; esta skill só cobra que o arquivo exista
  e esteja no lugar.
- **`schematize-models`** — roteamento de modelos e a regra de imagem que toda skill herda.
- **`schematize-shell`** — os scripts da skill obedecem ao piso de shell (o catálogo roda o gate nele).
- **`schematize-infra`** — CI/CD e supply chain do repo; aqui só o que a skill empacota.
