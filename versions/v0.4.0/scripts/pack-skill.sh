#!/usr/bin/env bash
# pack-skill.sh — empacota UMA skill em skill-<slug>.zip com top-level schematize-<slug>/.
#
# Motivo: o install.sh e o app schematize esperam o zip da release com a pasta de topo
# `schematize-<slug>/`; zip com layout errado instala em lugar nenhum. Este script reproduz o
# empacotamento de tools/release.mjs do catálogo (mesmos itens) para a 1ª release de skill nova
# ou para repo isolado.
# Como funciona: copia SKILL.md VERSION skill.toml references assets scripts gui.json CHANGELOG.md
# LICENSE para um temporário (mktemp, limpo no trap) sob schematize-<slug>/ e roda `zip -r -X`.
# Nunca entra no zip: .git, versions/, README.md, install.sh, *.zip.
# Entrada: $1 = diretório da skill · $2 = pasta de saída (default: o diretório atual).
# Saída: imprime o caminho do zip. exit 0 ok · 1 recusou · 2 uso / ferramenta ausente.
set -euo pipefail

DIR="${1:-}"; OUT="${2:-$PWD}"
[ -n "$DIR" ] && [ -d "$DIR" ] || { echo "uso: pack-skill.sh <diretório-da-skill> [pasta-de-saída]" >&2; exit 2; }
command -v zip >/dev/null 2>&1 || { echo "pack-skill: 'zip' não instalado (apt install zip)" >&2; exit 2; }
DIR="$(cd "$DIR" && pwd)"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
BASE="$(basename "$DIR")"
SLUG="${BASE#skill-}"
[ "$BASE" != "$SLUG" ] || { echo "pack-skill: o diretório deve se chamar skill-<slug> (veio '$BASE')" >&2; exit 1; }
[ -f "$DIR/SKILL.md" ] || { echo "pack-skill: SKILL.md ausente" >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP:?}"' EXIT INT TERM
mkdir -p "$TMP/schematize-$SLUG"
for item in SKILL.md VERSION skill.toml references assets scripts gui.json CHANGELOG.md LICENSE; do
  [ -e "$DIR/$item" ] && cp -R "$DIR/$item" "$TMP/schematize-$SLUG/"
done
ZIP="$OUT/skill-$SLUG.zip"
rm -f "$ZIP"
( cd "$TMP" && zip -q -r -X "$ZIP" "schematize-$SLUG" )
echo "$ZIP"
