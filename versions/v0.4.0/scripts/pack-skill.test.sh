#!/usr/bin/env bash
# Vermelho primeiro de pack-skill.sh: o zip sai com top-level schematize-<slug>/, SEM versions/,
# README, install.sh nem .git, e o script recusa diretório que não é skill-<slug>.
#
# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md`): harness de teste roda
# `set -u` sem `-e` — precisa continuar depois de um caso vermelho para reportar todos de uma vez.
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
P="$AQUI/pack-skill.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP:?}"' EXIT INT TERM
ok=0; fail=0

# esperar <nome> <exit-esperado> <exit-real>: registra o caso.
esperar() { if [ "$2" = "$3" ]; then echo "  ok $1"; ok=$((ok+1)); else echo "  x $1: exit $3, esperado $2"; fail=$((fail+1)); fi; }
# afirmar <nome> <comando...>: o comando tem de retornar 0.
afirmar() { local n="$1"; shift; if "$@"; then echo "  ok $n"; ok=$((ok+1)); else echo "  x $n"; fail=$((fail+1)); fi; }

D="$TMP/skill-docs"
mkdir -p "$D/references" "$D/assets/commands" "$D/scripts" "$D/versions/v0.1.0" "$D/.git"
for a in SKILL.md VERSION skill.toml CHANGELOG.md LICENSE README.md install.sh references/a.md assets/commands/dm-help.md scripts/x.sh versions/v0.1.0/SKILL.md .git/HEAD; do printf 'x\n' >"$D/$a"; done

echo "== verde"
OUT="$TMP/out"
Z="$(bash "$P" "$D" "$OUT" 2>&1)"; rc=$?
esperar "empacota" 0 "$rc"
afirmar "zip existe" test -f "$OUT/skill-docs.zip"
LISTA="$(unzip -Z1 "$OUT/skill-docs.zip" 2>/dev/null)"
afirmar "top-level schematize-docs/" bash -c '! grep -qvE "^schematize-docs/" <<<"$0"' "$LISTA"
afirmar "tem SKILL.md" grep -qx 'schematize-docs/SKILL.md' <<<"$LISTA"
afirmar "tem CHANGELOG e LICENSE" bash -c 'grep -qx "schematize-docs/CHANGELOG.md" <<<"$0" && grep -qx "schematize-docs/LICENSE" <<<"$0"' "$LISTA"
afirmar "tem references e scripts" bash -c 'grep -q "schematize-docs/references/a.md" <<<"$0" && grep -q "schematize-docs/scripts/x.sh" <<<"$0"' "$LISTA"
: "$Z"

echo "== vermelho: o que não pode entrar"
afirmar "sem versions/" bash -c '! grep -q "versions/" <<<"$0"' "$LISTA"
afirmar "sem README nem install.sh" bash -c '! grep -qE "README|install.sh" <<<"$0"' "$LISTA"
afirmar "sem .git" bash -c '! grep -q "\.git" <<<"$0"' "$LISTA"

echo "== vermelho: recusas"
mkdir -p "$TMP/semprefixo"; printf 'x\n' >"$TMP/semprefixo/SKILL.md"
bash "$P" "$TMP/semprefixo" "$OUT" >/dev/null 2>&1; esperar "diretório sem prefixo skill-" 1 "$?"
mkdir -p "$TMP/skill-vazia"
bash "$P" "$TMP/skill-vazia" "$OUT" >/dev/null 2>&1; esperar "sem SKILL.md" 1 "$?"
bash "$P" >/dev/null 2>&1; esperar "sem argumentos" 2 "$?"

echo
echo "resultado: $ok ok, $fail falhas"
[ "$fail" -eq 0 ]
