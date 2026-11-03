#!/usr/bin/env bash
# check-skill.sh — gate estático da schematize-skill-dev: audita UMA skill do catálogo contra o piso.
#
# Motivo: cada release reintroduzia a mesma classe de defeito (versão dessincronizada, description
# estourada, script sem teste, comando colidindo com o de outra skill). Tudo isso é visível no
# texto da skill, antes de qualquer release; este gate pega na hora, sem node e sem o catálogo.
# Como funciona: lê o diretório da skill (`skill-<slug>/`), aplica as regras abaixo e imprime
# achados `arquivo:linha: [ERRO|AVISO regra] mensagem`. Waiver rastreável: arquivo `.skill-ok` na
# raiz da skill, uma linha por dispensa: `<regra> <motivo>` (sem motivo não vale).
# Dispensa de teste por script: `lib.sh`/`*.lib.sh` (biblioteca sourceada) ou `# teste-ok: <motivo>` nas 30 primeiras linhas.
# Prefixo de comando = o do `<prefixo>-help.md` (pode ter hífen); <3 comandos de trabalho é AVISO.
# Entrada: $1 = diretório da skill (obrigatório). Env SKILL_DESC_MAX (default 190, teto da casa),
#   SKILL_DESC_ALVO (default = o teto, sem alvo menor), SKILL_CATALOGO (raiz com os skill-*/
#   irmãos, para checar colisão de prefixo; default: o pai do diretório).
# Saída: exit 0 passa (avisos não reprovam) · 1 reprova · 2 nada para verificar (não é aprovação).
#
# Regras (id): estrutura-arquivo · frontmatter · description-teto · description-gatilho ·
#   versao-ausente · versao-dessincronizada · versao-linha-multipla · changelog-defasado ·
#   snapshot-ausente · comando-prefixo · comando-obrigatorio · comando-frontmatter ·
#   comando-colisao · script-sem-teste · teste-sem-vermelho · teste-sem-verde · herdado-ausente ·
#   herdado-desbalanceado · ci-gatilho (piso 27) · i18n-ausente · anexo-volatil · emoji · zip-no-pacote · ci-pin · readme-contagem ·
#   caminho-privado.
#
# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md`): este script é um
# COLETOR — varre tudo e soma os achados; com `set -e` abortaria no primeiro `grep` sem casamento.
set -uo pipefail
export LC_ALL=C.UTF-8

DIR="${1:-}"
[ -n "$DIR" ] && [ -d "$DIR" ] || { echo "uso: check-skill.sh <diretório-da-skill>" >&2; exit 2; }
DIR="$(cd "$DIR" && pwd)"
[ -f "$DIR/SKILL.md" ] || [ -f "$DIR/skill.toml" ] || { echo "check-skill: '$DIR' não parece uma skill (sem SKILL.md nem skill.toml) — nada para verificar" >&2; exit 2; }

# Teto da casa: 190 chars (soma do catálogo <= 9000). Era 350/235 e deixava passar description que estoura o orçamento.
DESC_MAX="${SKILL_DESC_MAX:-190}"
DESC_ALVO="${SKILL_DESC_ALVO:-$DESC_MAX}"
BASE="$(basename "$DIR")"
SLUG="${BASE#skill-}"
CATALOGO="${SKILL_CATALOGO:-$(dirname "$DIR")}"

ACHADOS="$(mktemp)"
trap 'rm -f "$ACHADOS"' EXIT INT TERM
: >"$ACHADOS"

# emit <ERRO|AVISO> <regra> <arquivo> <linha> <msg>
emit() { printf '%s\t%s\t%s:%s: [%s %s] %s\n' "$1" "$2" "$3" "$4" "$1" "$2" "$5" >>"$ACHADOS"; }

# arquivos de texto da skill, sem snapshots nem git
lista_texto() {
  find "$DIR" -type f \( -name '*.md' -o -name '*.sh' -o -name '*.toml' -o -name '*.yml' -o -name '*.yaml' \) \
    -not -path '*/.git/*' -not -path '*/versions/*' | sort
}
rel() { printf '%s' "${1#"$DIR"/}"; }

# ---------------------------------------------------------------- estrutura
for a in SKILL.md skill.toml VERSION CHANGELOG.md README.md LICENSE install.sh assets/CLAUDE.md; do
  [ -f "$DIR/$a" ] || emit ERRO estrutura-arquivo "$a" 1 "arquivo obrigatório ausente"
done
for d in assets/commands scripts references; do
  [ -d "$DIR/$d" ] || emit ERRO estrutura-arquivo "$d" 1 "diretório obrigatório ausente"
done

# ---------------------------------------------------------------- frontmatter
FM_NAME=""; FM_VER=""; DESC=""
if [ -f "$DIR/SKILL.md" ]; then
  if [ "$(sed -n 1p "$DIR/SKILL.md")" != "---" ]; then
    emit ERRO frontmatter SKILL.md 1 "sem frontmatter (a 1ª linha deve ser ---)"
  else
    FM="$(awk 'NR==1{next} /^---[[:space:]]*$/{exit} {print}' "$DIR/SKILL.md")"
    FM_NAME="$(sed -n 's/^name:[[:space:]]*//p' <<<"$FM" | head -n1)"
    FM_VER="$(sed -n 's/^[[:space:]]\{2,\}version:[[:space:]]*//p' <<<"$FM" | head -n1)"
    [ "$FM_NAME" = "schematize-$SLUG" ] || emit ERRO frontmatter SKILL.md 2 "name '$FM_NAME' != 'schematize-$SLUG' (derivado do diretório)"
    if ! grep -qE '^description:[[:space:]]*>-[[:space:]]*$' <<<"$FM"; then
      emit ERRO frontmatter SKILL.md 1 "description deve ser bloco 'description: >-' (escalar solto quebra com ': ' no texto)"
    fi
    DESC="$(awk '/^description:/{d=1; next} d && /^[^[:space:]]/{exit} d{sub(/^[[:space:]]+/,""); printf "%s ", $0}' <<<"$FM" | sed 's/[[:space:]]*$//')"
    if [ -z "$DESC" ]; then
      emit ERRO frontmatter SKILL.md 1 "description ausente ou vazia"
    else
      n=${#DESC}
      if [ "$n" -gt "$DESC_MAX" ]; then
        emit ERRO description-teto SKILL.md 1 "description com $n chars (limite $DESC_MAX da casa: a soma do catálogo tem teto de 9000) — excede em $((n-DESC_MAX))"
      elif [ "$n" -gt "$DESC_ALVO" ]; then
        emit AVISO description-teto SKILL.md 1 "description com $n chars (alvo $DESC_ALVO: a soma do catálogo tem teto)"
      fi
      grep -qE '(^|[^[:alpha:]])(Use|Usar|Ao|Quando)[[:space:]]' <<<"$DESC" \
        || emit AVISO description-gatilho SKILL.md 1 "description sem gatilho concreto (\"Use ao tocar <artefato>\")"
    fi
  fi
fi

# ---------------------------------------------------------------- versão (4 lugares + changelog + snapshot)
V_FILE=""; V_TOML=""; V_LINHA=""
[ -f "$DIR/VERSION" ] && V_FILE="$(tr -d '[:space:]' <"$DIR/VERSION")"
[ -f "$DIR/skill.toml" ] && V_TOML="$(sed -n 's/^current_version[[:space:]]*=[[:space:]]*"\(.*\)"[[:space:]]*$/\1/p' "$DIR/skill.toml" | head -n1)"
NLINHAS=0
if [ -f "$DIR/SKILL.md" ]; then
  NLINHAS="$(grep -cE '^\*\*Vers(ã|a)o:\*\*' "$DIR/SKILL.md")"
  V_LINHA="$(grep -E '^\*\*Vers(ã|a)o:\*\*' "$DIR/SKILL.md" | head -n1 | sed -n 's/.*[[:space:]]v\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p')"
fi
for par in "VERSION:$V_FILE" "skill.toml:$V_TOML" "SKILL.md(frontmatter):$FM_VER" "SKILL.md(linha):$V_LINHA"; do
  [ -n "${par#*:}" ] || emit ERRO versao-ausente "${par%%:*}" 1 "versão ausente"
done
distintas="$(printf '%s\n' "$V_FILE" "$V_TOML" "$FM_VER" "$V_LINHA" | grep -v '^$' | sort -u | wc -l)"
if [ "$distintas" -gt 1 ]; then
  emit ERRO versao-dessincronizada VERSION 1 "VERSION=$V_FILE skill.toml=$V_TOML frontmatter=$FM_VER linha=$V_LINHA (os 4 lugares devem ser iguais)"
fi
[ "$NLINHAS" -gt 1 ] && emit AVISO versao-linha-multipla SKILL.md 1 "$NLINHAS linhas '**Versão:**' (só a 1ª é conferida e atualizada pelo release)"
if [ -n "$V_FILE" ]; then
  if [ -f "$DIR/CHANGELOG.md" ]; then
    topo="$(sed -n 's/^##[[:space:]]*\[\{0,1\}v\{0,1\}\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p' "$DIR/CHANGELOG.md" | head -n1)"
    if [ -z "$topo" ]; then
      emit ERRO changelog-defasado CHANGELOG.md 1 "sem cabeçalho de versão ('## [X.Y.Z] — data')"
    elif [ "$(printf '%s\n%s\n' "$topo" "$V_FILE" | sort -V | head -n1)" != "$V_FILE" ]; then
      emit ERRO changelog-defasado CHANGELOG.md 1 "topo do CHANGELOG é $topo, mas VERSION é $V_FILE (falta a entrada de $V_FILE)"
    fi
  fi
  [ -d "$DIR/versions/v$V_FILE" ] || emit ERRO snapshot-ausente "versions/v$V_FILE" 1 "snapshot da versão vigente não existe (o release o cria; na 1ª versão, à mão)"
fi

# ---------------------------------------------------------------- comandos
PREFIXOS=""
if [ -d "$DIR/assets/commands" ]; then
  # Prefixo declarado = o do único `<prefixo>-help.md` (aceita hífen: `overdev-context-help` -> `overdev-context`).
  # O help do catálogo (schematize-engineering → assets/commands/schematize-help.md) é o help do catálogo inteiro, não entra na conta.
  HELPS=""
  for f in "$DIR"/assets/commands/*-help.md; do
    [ -e "$f" ] || continue
    b="$(basename "$f" .md)"
    [ "$SLUG" = engineering ] && [ "$b" = schematize-help ] && continue
    HELPS="$HELPS ${b%-help}"
  done
  PDECL=""
  [ "$(wc -w <<<"$HELPS")" -eq 1 ] && PDECL="${HELPS# }"
  for f in "$DIR"/assets/commands/*.md; do
    [ -e "$f" ] || continue
    b="$(basename "$f" .md)"
    [ "$SLUG" = engineering ] && [ "$b" = schematize-help ] && { :; } || {
      if [ -n "$PDECL" ]; then
        case "$b" in "$PDECL"-*) p="$PDECL" ;; *) p="${b%%-*}" ;; esac
      else p="${b%%-*}"; fi
      case " $PREFIXOS " in *" $p "*) ;; *) PREFIXOS="$PREFIXOS $p" ;; esac
    }
    if [ "$(sed -n 1p "$f")" != "---" ] || ! sed -n '2,6p' "$f" | grep -qE '^description:[[:space:]]*[^[:space:]]'; then
      emit ERRO comando-frontmatter "assets/commands/$b.md" 1 "comando sem frontmatter com 'description:'"
    fi
  done
  nprefixos="$(wc -w <<<"$PREFIXOS")"
  if [ "$nprefixos" -gt 1 ]; then
    emit ERRO comando-prefixo assets/commands 1 "mais de um prefixo de comando (${PREFIXOS# }): use um prefixo único por skill"
  elif [ "$nprefixos" -eq 1 ]; then
    P="${PREFIXOS# }"
    for o in help load claude handoff cc; do
      [ -f "$DIR/assets/commands/$P-$o.md" ] || emit ERRO comando-obrigatorio "assets/commands/$P-$o.md" 1 "comando obrigatório ausente"
    done
    ntrab="$(find "$DIR/assets/commands" -name "$P-*.md" | grep -cvE "/$P-(help|load|claude|handoff|cc)\.md$")"
    [ "$ntrab" -ge 3 ] || emit AVISO comando-obrigatorio assets/commands 1 "$ntrab comando(s) de trabalho (o ideal é 3 a 5; aviso, não erro)"
    for irma in "$CATALOGO"/skill-*; do
      [ -d "$irma/assets/commands" ] && [ "$(cd "$irma" && pwd)" != "$DIR" ] || continue
      for c in "$irma"/assets/commands/*.md; do
        [ -e "$c" ] || continue
        if [ -f "$DIR/assets/commands/$(basename "$c")" ]; then
          emit ERRO comando-colisao "assets/commands/$(basename "$c")" 1 "comando já existe em $(basename "$irma") (prefixo deve ser único no catálogo)"
        fi
      done
    done
  fi
fi

# ---------------------------------------------------------------- scripts e testes
if [ -d "$DIR/scripts" ]; then
  for s in "$DIR"/scripts/*.sh; do
    [ -e "$s" ] || continue
    b="$(basename "$s")"
    case "$b" in *.test.sh) continue ;; esac
    t="$DIR/scripts/${b%.sh}.test.sh"
    # biblioteca sourceada (`lib.sh`, `*.lib.sh`) é isenta; outras, só com `# teste-ok:` no cabeçalho
    case "$b" in lib.sh|*.lib.sh) continue ;; esac
    # biblioteca sourceada, coberta pelos testes dos scripts que a usam: `# teste-ok: <motivo>` no cabeçalho
    head -n 30 "$s" | grep -qE '#[[:space:]]*teste-ok:[[:space:]]*[^[:space:]]+' && continue
    if [ ! -f "$t" ]; then
      emit ERRO script-sem-teste "scripts/$b" 1 "script sem scripts/${b%.sh}.test.sh (gate sem vermelho plantado é decoração)"
      continue
    fi
    grep -qF "$b" "$t" || emit ERRO script-sem-teste "scripts/${b%.sh}.test.sh" 1 "o teste não referencia $b"
    grep -qE 'esperar[[:space:]]+[12]\b|exit[[:space:]]+[12]\b|-ne[[:space:]]+0|!=[[:space:]]*0|vermelho' "$t" \
      || emit ERRO teste-sem-vermelho "scripts/${b%.sh}.test.sh" 1 "nenhum caso vermelho identificável (esperar 1/2, rc != 0)"
    grep -qE 'esperar[[:space:]]+0\b|-eq[[:space:]]+0|==[[:space:]]*0|verde' "$t" \
      || emit ERRO teste-sem-verde "scripts/${b%.sh}.test.sh" 1 "nenhum caso verde identificável (esperar 0): o gate pode reprovar tudo"
  done
fi

# ---------------------------------------------------------------- herdados
# A base (engineering) é a FONTE dos blocos herdados: não herda de si mesma.
if [ "$SLUG" != "engineering" ] && [ -f "$DIR/SKILL.md" ]; then
  grep -q '<!-- herdado:engineering/orquestracao' "$DIR/SKILL.md" || emit ERRO herdado-ausente SKILL.md 1 "falta o bloco herdado engineering/orquestracao"
  grep -q '<!-- herdado:engineering/precedencia' "$DIR/SKILL.md" || emit ERRO herdado-ausente SKILL.md 1 "falta o bloco herdado engineering/precedencia"
fi
if [ "$SLUG" != "engineering" ] && [ -f "$DIR/assets/CLAUDE.md" ]; then
  grep -q '<!-- herdado:engineering/orquestracao' "$DIR/assets/CLAUDE.md" || emit ERRO herdado-ausente assets/CLAUDE.md 1 "falta o bloco herdado engineering/orquestracao"
fi
while IFS= read -r f; do
  case "$f" in *.md) ;; *) continue ;; esac
  # conta só marcadores no início de bloco (herdado:x/y:z ... -->) e o fechamento literal
  ab="$(grep -oE '<!-- herdado:[a-z0-9-]+/[a-z0-9-]+:[a-z0-9-]+' "$f" | wc -l)"
  fe="$(grep -oF '<!-- /herdado -->' "$f" | wc -l)"
  [ "$ab" -eq "$fe" ] || emit ERRO herdado-desbalanceado "$(rel "$f")" 1 "$ab abertura(s) de bloco herdado e $fe fechamento(s)"
done < <(lista_texto)

# ---------------------------------------------------------------- anexo volátil
ANEXO="$DIR/references/stack-versoes.md"
if [ -f "$ANEXO" ]; then
  grep -qE 'Verificado em:?\**[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$ANEXO" \
    || emit ERRO anexo-volatil references/stack-versoes.md 1 "anexo volátil sem 'Verificado em: AAAA-MM-DD'"
else
  emit AVISO anexo-volatil references/stack-versoes.md 1 "sem anexo volátil: ok só se a skill não fixa nenhum fato com prazo de validade"
fi

# ---------------------------------------------------------------- higiene
EMOJI_RE='[\x{1F300}-\x{1FAFF}\x{2705}\x{274C}\x{2B50}\x{FE0F}]'
while IFS= read -r f; do
  case "$f" in *.md|*.sh|*.toml) ;; *) continue ;; esac
  n="$(grep -nP "$EMOJI_RE" "$f" 2>/dev/null | head -n1 | cut -d: -f1)"
  [ -n "$n" ] && emit ERRO emoji "$(rel "$f")" "$n" "emoji na estrutura (piso da casa: ícones, nunca emoji)"
done < <(lista_texto)
while IFS= read -r z; do
  emit ERRO zip-no-pacote "$(rel "$z")" 1 "zip de distribuição dentro do pacote (exclua *.zip no install.sh e no empacotamento)"
done < <(find "$DIR" -type f -name '*.zip' -not -path '*/.git/*' | sort)
# caminho privado da máquina: o padrão é montado em partes para o gate não se acusar
PRIV="/ho""me/[a-z][a-z0-9_-]*/"
while IFS= read -r f; do
  n="$(grep -nE "$PRIV" "$f" | head -n1 | cut -d: -f1)"
  [ -n "$n" ] && emit ERRO caminho-privado "$(rel "$f")" "$n" "caminho privado da máquina no pacote (a skill roda em qualquer máquina)"
done < <(lista_texto)
if [ -d "$DIR/assets/ci" ]; then
  for y in "$DIR"/assets/ci/*.yml "$DIR"/assets/ci/*.yaml; do
    [ -e "$y" ] || continue
    while IFS=: read -r n resto; do
      u="$(sed -n 's/.*uses:[[:space:]]*\([^[:space:]#]*\).*/\1/p' <<<"$resto")"
      case "$u" in ./*) continue ;; esac
      grep -qE '@[0-9a-f]{40}$' <<<"$u" || emit ERRO ci-pin "$(rel "$y")" "$n" "uses: $u não está pinado por SHA de 40 hex"
    done < <(grep -nE '^[[:space:]-]*uses:' "$y")
  done
fi

# ---------------------------------------------------------------- gatilho de CI (piso 27) e i18n
# Template de CI nasce com workflow_dispatch + push em TAGS e concurrency cancel-in-progress. VETADO
# pull_request/pull_request_target/workflow_run/merge_group/schedule e push/branches (CI remoto por commit).
if [ -d "$DIR/assets/ci" ]; then
  for y in "$DIR"/assets/ci/*.yml "$DIR"/assets/ci/*.yaml; do
    [ -e "$y" ] || continue
    sem="$(grep -vE '^[[:space:]]*#' "$y")"
    n="$(grep -nE '^[[:space:]]*(pull_request|pull_request_target|workflow_run|merge_group|schedule)[[:space:]]*:|^on:[[:space:]]*(\[.*(pull_request|push|schedule|workflow_run|merge_group)|(pull_request|push|schedule))|^[[:space:]]+(branches|branches-ignore|tags-ignore):' "$y" | grep -vE '^[0-9]+:[[:space:]]*#' | head -n1 | cut -d: -f1)"
    if [ -n "$n" ]; then
      emit ERRO ci-gatilho "$(rel "$y")" "$n" "gatilho vetado pelo piso 27 (pull_request/push em branch/workflow_run/schedule): use workflow_dispatch + push tags [hml-*, v*]"
    elif ! grep -qE '^[[:space:]]*workflow_dispatch[[:space:]]*:' <<<"$sem" || ! grep -qE 'cancel-in-progress:[[:space:]]*true' <<<"$sem"; then
      emit ERRO ci-gatilho "$(rel "$y")" 1 "template de CI sem workflow_dispatch ou sem concurrency cancel-in-progress: true (piso 27)"
    fi
  done
fi
if [ -f "$DIR/skill.toml" ]; then
  for lg in pt en es; do
    awk -v k="$lg" '/^\[descriptions\]/{d=1; next} /^\[/{d=0} d && $0 ~ "^"k"[[:space:]]*=" {v=$0; sub(/^[^=]*=[[:space:]]*/,"",v); gsub(/["[:space:]]/,"",v); if (length(v)>0) ok=1} END{exit ok?0:1}' "$DIR/skill.toml" \
      || emit ERRO i18n-ausente skill.toml 1 "[descriptions] sem '$lg' (pt, en e es são obrigatórios)"
  done
fi

# ---------------------------------------------------------------- README x SKILL (contagem de pisos)
if [ -f "$DIR/SKILL.md" ] && [ -f "$DIR/README.md" ]; then
  reais="$(awk '/^## Pisos/{d=1; next} d && /^## /{exit} d && /^[0-9]+\.[[:space:]]/{n++} END{print n+0}' "$DIR/SKILL.md")"
  dito="$(grep -oE '[0-9]+[[:space:]]+pisos[[:space:]]+inegoci' "$DIR/README.md" | head -n1 | grep -oE '^[0-9]+')"
  if [ "$reais" -gt 0 ] && [ -n "$dito" ] && [ "$dito" != "$reais" ]; then
    emit ERRO readme-contagem README.md 1 "README diz $dito pisos; o SKILL.md tem $reais"
  fi
fi

# ---------------------------------------------------------------- waivers e veredito
erros=0; avisos=0
dispensa() { [ -f "$DIR/.skill-ok" ] && grep -qE "^$1[[:space:]]+[^[:space:]]+" "$DIR/.skill-ok"; }
while IFS="$(printf '\t')" read -r sev regra linha; do
  if dispensa "$regra"; then
    echo "$linha (dispensado por .skill-ok)"
    continue
  fi
  echo "$linha"
  if [ "$sev" = ERRO ]; then erros=$((erros+1)); else avisos=$((avisos+1)); fi
done <"$ACHADOS"

if [ "$erros" -gt 0 ]; then
  echo "check-skill: REPROVADO — $erros erro(s), $avisos aviso(s) em $BASE" >&2
  exit 1
fi
echo "check-skill: ok — $BASE ($avisos aviso(s))"
