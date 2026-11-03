#!/usr/bin/env bash
# Vermelho primeiro do gate check-skill.sh. Cada caso é uma skill de mentira com UM defeito plantado
# (e uma verde que tem de passar limpa, para provar que o gate não reprova tudo).
#
# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md`): harness de teste roda
# `set -u` sem `-e` — precisa continuar depois de um caso vermelho para reportar todos de uma vez.
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
G="$AQUI/check-skill.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP:?}"' EXIT INT TERM
ok=0; fail=0
D=""; NOME=""

# esperar <exit> <agulha>: roda o gate na skill do caso atual e confere exit code e trecho da saída.
esperar() {
  local esp="$1" agulha="$2" saida rc
  saida="$(bash "$G" "$D" 2>&1)"; rc=$?
  if [ "$rc" != "$esp" ]; then echo "  x $NOME: exit $rc, esperado $esp"; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return; fi
  if [ -n "$agulha" ] && ! grep -qF -- "$agulha" <<<"$saida"; then
    echo "  x $NOME: exit certo, saída sem \"$agulha\""; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return
  fi
  echo "  ok $NOME"; ok=$((ok+1))
}

# skill_boa <nome-do-caso>: cria o diretório skill-docs dentro de TMP/<caso> completa e válida; D aponta para ela.
skill_boa() {
  NOME="$1"; D="$TMP/$1/skill-docs"
  mkdir -p "$D/assets/commands" "$D/scripts" "$D/references" "$D/versions/v0.1.0" "$TMP/$1/skill-irma/assets/commands"
  printf '0.1.0\n' >"$D/VERSION"
  printf 'MIT\n' >"$D/LICENSE"
  printf '#!/usr/bin/env bash\n' >"$D/install.sh"
  printf 'slug = "demo"\ncurrent_version = "0.1.0"\n\n[descriptions]\npt = "demo"\nen = "demo"\nes = "demo"\n' >"$D/skill.toml"
  printf '# Demo\n\nO pacote tem 2 pisos inegociáveis.\n' >"$D/README.md"
  printf '# Changelog\n\n## [0.1.0] — 2026-10-14\nPrimeira versão.\n' >"$D/CHANGELOG.md"
  printf '# Piso\n\n1. regra\n<!-- herdado:engineering/orquestracao:curto -->x<!-- /herdado -->\n' >"$D/assets/CLAUDE.md"
  printf '# Anexo\n\n> **Verificado em: 2026-10-14.**\n' >"$D/references/stack-versoes.md"
  cat >"$D/SKILL.md" <<'FIX'
---
name: schematize-docs
metadata:
  version: 0.1.0
description: >-
  Skill de teste do gate. Use ao tocar demo.txt. Divisa: schematize-docs.
---
# Demo

**Versão:** skill `schematize-docs` v0.1.0.

<!-- herdado:engineering/precedencia:dominio intro="x" cmd="dm" -->x<!-- /herdado -->

## Pisos inegociáveis

1. regra um
2. regra dois
   <!-- herdado:engineering/orquestracao:curto -->x<!-- /herdado -->

## Fim
FIX
  for c in help load claude handoff cc a b c; do
    printf -- '---\ndescription: comando %s\n---\ncorpo\n' "$c" >"$D/assets/commands/dm-$c.md"
  done
  printf -- '---\ndescription: de outra skill\n---\ncorpo\n' >"$TMP/$1/skill-irma/assets/commands/zz-help.md"
  printf '#!/usr/bin/env bash\nset -euo pipefail\necho ok\n' >"$D/scripts/check-x.sh"
  printf '#!/usr/bin/env bash\nset -u\nesperar 1 vermelho\nesperar 0 verde\n# check-x.sh\n' >"$D/scripts/check-x.test.sh"
}

echo "== verde"
skill_boa verde-completa;                   esperar 0 "check-skill: ok"

echo "== vermelho: estrutura e frontmatter"
skill_boa sem-license;                      rm "$D/LICENSE";                        esperar 1 "estrutura-arquivo"
skill_boa sem-claude-md;                    rm "$D/assets/CLAUDE.md";               esperar 1 "assets/CLAUDE.md"
skill_boa name-errado;                      sed -i 's/^name: .*/name: schematize-qa/' "$D/SKILL.md"; esperar 1 "name 'schematize-qa'"
skill_boa description-escalar;              sed -i 's/^description: >-/description: Skill de teste./' "$D/SKILL.md"; esperar 1 "description deve ser bloco"
skill_boa sem-frontmatter;                  sed -i '1d' "$D/SKILL.md";              esperar 1 "sem frontmatter"

echo "== vermelho: description"
skill_boa description-longa
  { printf '  '; head -c 400 /dev/zero | tr '\0' 'a'; printf ' Use ao tocar x.\n'; } >"$TMP/longa.txt"
  sed -i "/^  Skill de teste/{r $TMP/longa.txt
d}" "$D/SKILL.md";                                                                esperar 1 "description-teto"
skill_boa description-191;
  { printf '  '; head -c 120 /dev/zero | tr '\0' 'a'; printf ' Use ao tocar x. Divisa: schematize-docs'; } >"$TMP/d191.txt"
  tam=$(( $(wc -c <"$TMP/d191.txt") - 2 )); extra=$(( 191 - tam )); [ "$extra" -gt 0 ] && head -c "$extra" /dev/zero | tr '\0' 'b' >>"$TMP/d191.txt"; echo >>"$TMP/d191.txt"
  sed -i "/^  Skill de teste/{r $TMP/d191.txt
d}" "$D/SKILL.md";                                                                esperar 1 "description-teto"
skill_boa description-190-passa;
  { printf '  '; head -c 120 /dev/zero | tr '\0' 'a'; printf ' Use ao tocar x. Divisa: schematize-docs'; } >"$TMP/d190.txt"
  tam=$(( $(wc -c <"$TMP/d190.txt") - 2 )); extra=$(( 190 - tam )); [ "$extra" -gt 0 ] && head -c "$extra" /dev/zero | tr '\0' 'b' >>"$TMP/d190.txt"; echo >>"$TMP/d190.txt"
  sed -i "/^  Skill de teste/{r $TMP/d190.txt
d}" "$D/SKILL.md";                                                                esperar 0 "check-skill: ok"
skill_boa description-sem-gatilho;          sed -i 's/Use ao tocar demo.txt\. //' "$D/SKILL.md"; esperar 0 "AVISO description-gatilho"

echo "== vermelho: versão"
skill_boa versao-toml-diverge;              sed -i 's/0.1.0/0.2.0/' "$D/skill.toml"; esperar 1 "versao-dessincronizada"
skill_boa versao-linha-diverge;             sed -i 's/ v0.1.0\./ v0.0.9./' "$D/SKILL.md"; esperar 1 "versao-dessincronizada"
skill_boa versao-sem-linha;                 sed -i '/^\*\*Versão:\*\*/d' "$D/SKILL.md"; esperar 1 "versao-ausente"
skill_boa changelog-atrasado;               printf '0.2.0\n' >"$D/VERSION"; sed -i 's/0.1.0/0.2.0/' "$D/skill.toml" "$D/SKILL.md"; mkdir -p "$D/versions/v0.2.0"; esperar 1 "changelog-defasado"
skill_boa snapshot-ausente;                 rmdir "$D/versions/v0.1.0";             esperar 1 "snapshot-ausente"

echo "== vermelho: comandos"
skill_boa comando-help-ausente;             rm "$D/assets/commands/dm-help.md";     esperar 1 "comando-obrigatorio"
skill_boa comando-poucos-de-trabalho;       rm "$D/assets/commands/dm-b.md" "$D/assets/commands/dm-c.md"; esperar 0 "AVISO comando-obrigatorio"
skill_boa comando-prefixo-com-hifen
  rm "$D"/assets/commands/dm-*.md
  for c in help load claude handoff cc a b c; do printf -- '---\ndescription: x\n---\ncorpo\n' >"$D/assets/commands/dm-ctx-$c.md"; done; esperar 0 "check-skill: ok"
skill_boa comando-hifen-sem-help;           rm "$D"/assets/commands/dm-help.md; cp "$D/assets/commands/dm-a.md" "$D/assets/commands/dm-ctx-a.md"; esperar 1 "comando-"
skill_boa help-catalogo-na-engineering;     mv "$D" "$TMP/$NOME/skill-engineering"; D="$TMP/$NOME/skill-engineering"; sed -i '/herdado:/d' "$D/SKILL.md" "$D/assets/CLAUDE.md"; sed -i 's/schematize-docs/schematize-engineering/' "$D/SKILL.md"; printf -- '---\ndescription: x\n---\nc\n' >"$D/assets/commands/schematize-help.md"; esperar 0 "check-skill: ok"
skill_boa help-catalogo-fora-da-engineering; printf -- '---\ndescription: x\n---\nc\n' >"$D/assets/commands/schematize-help.md"; esperar 1 "comando-prefixo"
skill_boa comando-dois-prefixos;            cp "$D/assets/commands/dm-a.md" "$D/assets/commands/xx-a.md"; esperar 1 "comando-prefixo"
skill_boa comando-sem-description;          printf 'corpo sem frontmatter\n' >"$D/assets/commands/dm-a.md"; esperar 1 "comando-frontmatter"
skill_boa comando-colide-com-irma;          cp "$D/assets/commands/dm-a.md" "$TMP/$NOME/skill-irma/assets/commands/dm-a.md"; esperar 1 "comando-colisao"

echo "== vermelho: scripts e testes"
skill_boa script-sem-teste;                 rm "$D/scripts/check-x.test.sh";        esperar 1 "script-sem-teste"
skill_boa lib-com-teste-ok;                 printf '#!/usr/bin/env bash\n# teste-ok: coberta pelos testes de check-x.sh\n' >"$D/scripts/helper.sh"; esperar 0 "check-skill: ok"
skill_boa lib-sh-isenta;                    printf '#!/usr/bin/env bash\n' >"$D/scripts/lib.sh"; printf '#!/usr/bin/env bash\n' >"$D/scripts/util.lib.sh"; esperar 0 "check-skill: ok"
skill_boa lib-com-teste-ok-sem-motivo;      printf '#!/usr/bin/env bash\n# teste-ok:\n' >"$D/scripts/helper.sh"; esperar 1 "script-sem-teste"
skill_boa teste-nao-referencia-script;      printf 'esperar 1 a\nesperar 0 b\n' >"$D/scripts/check-x.test.sh"; esperar 1 "não referencia"
skill_boa teste-sem-vermelho;               printf '# check-x.sh\nesperar 0 verde\n' >"$D/scripts/check-x.test.sh"; esperar 1 "teste-sem-vermelho"
skill_boa teste-sem-verde;                  printf '# check-x.sh\nesperar 1 vermelho\n' >"$D/scripts/check-x.test.sh"; esperar 1 "teste-sem-verde"

echo "== vermelho: herdados e anexo"
skill_boa base-nao-herda-de-si;             mv "$D" "$TMP/$NOME/skill-engineering"; D="$TMP/$NOME/skill-engineering"; sed -i '/herdado:/d' "$D/SKILL.md" "$D/assets/CLAUDE.md"; sed -i 's/schematize-docs/schematize-engineering/' "$D/SKILL.md"; esperar 0 "check-skill: ok"
skill_boa sem-bloco-precedencia;            sed -i '/precedencia:dominio/d' "$D/SKILL.md"; esperar 1 "herdado-ausente"
skill_boa claude-md-sem-orquestracao;       printf '# Piso\n' >"$D/assets/CLAUDE.md"; esperar 1 "assets/CLAUDE.md"
skill_boa bloco-nao-fechado;                printf '<!-- herdado:engineering/x:y -->solto\n' >>"$D/references/a.md"; esperar 1 "herdado-desbalanceado"
skill_boa anexo-sem-data;                   printf '# Anexo\n' >"$D/references/stack-versoes.md"; esperar 1 "anexo-volatil"

echo "== vermelho: higiene"
skill_boa emoji;                            printf 'ótimo \xf0\x9f\x9a\x80\n' >>"$D/references/a.md"; esperar 1 "emoji"
skill_boa zip-no-pacote;                    : >"$D/skill-docs.zip";                  esperar 1 "zip-no-pacote"
skill_boa caminho-privado;                  printf 'veja %s\n' "/ho""me/fulano/projeto" >>"$D/references/a.md"; esperar 1 "caminho-privado"
skill_boa ci-sem-sha
  mkdir -p "$D/assets/ci"; printf 'jobs:\n  a:\n    steps:\n      - uses: actions/checkout@v4\n' >"$D/assets/ci/w.yml"; esperar 1 "ci-pin"
skill_boa ci-com-sha
  mkdir -p "$D/assets/ci"; printf 'on:\n  workflow_dispatch:\nconcurrency:\n  cancel-in-progress: true\njobs:\n  a:\n    steps:\n      - uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4\n' >"$D/assets/ci/w.yml"; esperar 0 "check-skill: ok"
skill_boa ci-pull-request
  mkdir -p "$D/assets/ci"; printf 'on:\n  pull_request:\n  workflow_dispatch:\nconcurrency:\n  cancel-in-progress: true\njobs: {}\n' >"$D/assets/ci/w.yml"; esperar 1 "ci-gatilho"
skill_boa ci-push-branch
  mkdir -p "$D/assets/ci"; printf 'on:\n  workflow_dispatch:\n  push:\n    branches: [main]\nconcurrency:\n  cancel-in-progress: true\njobs: {}\n' >"$D/assets/ci/w.yml"; esperar 1 "ci-gatilho"
skill_boa ci-sem-concurrency
  mkdir -p "$D/assets/ci"; printf 'on:\n  workflow_dispatch:\njobs: {}\n' >"$D/assets/ci/w.yml"; esperar 1 "ci-gatilho"
skill_boa ci-dispatch-tags-ok
  mkdir -p "$D/assets/ci"; printf 'on:\n  workflow_dispatch:\n  push:\n    tags: ["hml-*", "v*"]\nconcurrency:\n  cancel-in-progress: true\njobs: {}\n' >"$D/assets/ci/w.yml"; esperar 0 "check-skill: ok"
skill_boa i18n-sem-es;                      sed -i '/^es = /d' "$D/skill.toml"; esperar 1 "i18n-ausente"
skill_boa i18n-en-vazio;                    sed -i 's/^en = .*/en = ""/' "$D/skill.toml"; esperar 1 "i18n-ausente"
skill_boa readme-conta-errado;              sed -i 's/2 pisos/9 pisos/' "$D/README.md"; esperar 1 "readme-contagem"

echo "== waiver rastreável e entradas inválidas"
skill_boa waiver-com-motivo;                rm "$D/LICENSE"; printf 'estrutura-arquivo licença vem do monorepo\n' >"$D/.skill-ok"; esperar 0 "dispensado por .skill-ok"
skill_boa waiver-sem-motivo;                rm "$D/LICENSE"; printf 'estrutura-arquivo\n' >"$D/.skill-ok"; esperar 1 "estrutura-arquivo"
NOME="dir-inexistente"; D="$TMP/nao-existe";                                       esperar 2 "uso:"
NOME="dir-vazio"; D="$TMP/vazio"; mkdir -p "$D";                                    esperar 2 "nada para verificar"

echo
echo "resultado: $ok ok, $fail falhas"
[ "$fail" -eq 0 ]
