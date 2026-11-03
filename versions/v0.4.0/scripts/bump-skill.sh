#!/usr/bin/env bash
# bump-skill.sh — sobe a versão de UMA skill nos 4 lugares do repo e grava o snapshot versions/v<ver>/.
#
# Motivo: o bump à mão esquece um dos 4 lugares (VERSION, skill.toml, frontmatter, linha **Versão:**)
# e o lint reprova no release seguinte. Este script reproduz o `bump` + `snapshot` de tools/release.mjs
# do catálogo para quem não tem o catálogo ao lado (1ª versão de skill nova, repo isolado).
# Como funciona: valida SemVer, exige versão MAIOR que a atual e a 1ª entrada do CHANGELOG.md igual
# à nova; reescreve os 4 lugares; copia SKILL.md VERSION skill.toml references assets scripts
# gui.json para versions/v<ver>/. Não faz git, tag nem release.
# Entrada: $1 = diretório da skill · $2 = nova versão X.Y.Z (sem "v"). Env: --dry-run como $3.
# Saída: exit 0 bumpou (ou simulou) · 1 recusou (nada foi alterado) · 2 uso.
set -euo pipefail

DIR="${1:-}"; VER="${2:-}"; MODO="${3:-}"
[ -n "$DIR" ] && [ -n "$VER" ] || { echo "uso: bump-skill.sh <diretório-da-skill> <X.Y.Z> [--dry-run]" >&2; exit 2; }
[ -d "$DIR" ] || { echo "bump-skill: '$DIR' não é diretório" >&2; exit 2; }
DIR="$(cd "$DIR" && pwd)"
[[ "$VER" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "bump-skill: versão inválida '$VER' (use X.Y.Z, sem v)" >&2; exit 1; }
for a in VERSION skill.toml SKILL.md CHANGELOG.md; do
  [ -f "$DIR/$a" ] || { echo "bump-skill: $a ausente em $DIR" >&2; exit 1; }
done

ATUAL="$(tr -d '[:space:]' <"$DIR/VERSION")"
if [ "$(printf '%s\n%s\n' "$ATUAL" "$VER" | sort -V | tail -n1)" != "$VER" ] || [ "$ATUAL" = "$VER" ]; then
  echo "bump-skill: $VER não é maior que a atual ($ATUAL)" >&2; exit 1
fi
TOPO="$(sed -n 's/^##[[:space:]]*\[\{0,1\}v\{0,1\}\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p' "$DIR/CHANGELOG.md" | head -n1)"
[ "$TOPO" = "$VER" ] || { echo "bump-skill: a 1ª entrada do CHANGELOG.md é '${TOPO:-nenhuma}', esperado $VER — escreva a entrada (com o PORQUÊ) antes" >&2; exit 1; }
grep -qE '^current_version[[:space:]]*=' "$DIR/skill.toml" || { echo "bump-skill: skill.toml sem current_version" >&2; exit 1; }
grep -qE '^[[:space:]]{2,}version:[[:space:]]*[^[:space:]]+' "$DIR/SKILL.md" || { echo "bump-skill: SKILL.md sem metadata.version no frontmatter" >&2; exit 1; }
grep -qE '^\*\*Vers(ã|a)o:\*\*.*[[:space:]]v[0-9]+\.[0-9]+\.[0-9]+' "$DIR/SKILL.md" || { echo "bump-skill: SKILL.md sem a linha '**Versão:** ... vX.Y.Z'" >&2; exit 1; }

if [ "$MODO" = "--dry-run" ]; then
  echo "bump-skill: (dry-run) $ATUAL -> $VER em $(basename "$DIR"); nada gravado"
  exit 0
fi

printf '%s\n' "$VER" >"$DIR/VERSION"
sed -i "s/^current_version[[:space:]]*=.*/current_version = \"$VER\"/" "$DIR/skill.toml"
# só a 1ª ocorrência de cada padrão (o release também só mexe na 1ª)
sed -i "0,/^\([[:space:]]\{2,\}version:[[:space:]]*\)[^[:space:]]\+/s//\1$VER/" "$DIR/SKILL.md"
sed -i "0,/^\(\*\*Vers\(ã\|a\)o:\*\*.*[[:space:]]v\)[0-9]\+\.[0-9]\+\.[0-9]\+/s//\1$VER/" "$DIR/SKILL.md"

SNAP="$DIR/versions/v$VER"
rm -rf "${SNAP:?}"
mkdir -p "$SNAP"
for item in SKILL.md VERSION skill.toml references assets scripts gui.json; do
  [ -e "$DIR/$item" ] && cp -R "$DIR/$item" "$SNAP/"
done
echo "bump-skill: $ATUAL -> $VER em $(basename "$DIR") (VERSION, skill.toml, frontmatter, linha) + snapshot versions/v$VER/"
