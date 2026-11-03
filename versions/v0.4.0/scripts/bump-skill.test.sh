#!/usr/bin/env bash
# Vermelho primeiro de bump-skill.sh: o bump recusa o que o release recusaria e, quando passa, deixa
# os 4 lugares iguais (o check-skill.sh confirma).
#
# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md`): harness de teste roda
# `set -u` sem `-e` — precisa continuar depois de um caso vermelho para reportar todos de uma vez.
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
B="$AQUI/bump-skill.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP:?}"' EXIT INT TERM
ok=0; fail=0; D=""; NOME=""

# esperar <exit> <agulha> <args...>: roda o bump com os args e confere exit code e trecho da saída.
esperar() {
  local esp="$1" agulha="$2" saida rc; shift 2
  saida="$(bash "$B" "$@" 2>&1)"; rc=$?
  if [ "$rc" != "$esp" ]; then echo "  x $NOME: exit $rc, esperado $esp"; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return; fi
  if [ -n "$agulha" ] && ! grep -qF -- "$agulha" <<<"$saida"; then echo "  x $NOME: saída sem \"$agulha\""; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return; fi
  echo "  ok $NOME"; ok=$((ok+1))
}

# skill <caso> <changelog-topo>: skill mínima na 0.1.0 com a 1ª entrada do CHANGELOG indicada.
skill() {
  NOME="$1"; D="$TMP/$1/skill-docs"
  mkdir -p "$D/references" "$D/assets" "$D/scripts"
  printf '0.1.0\n' >"$D/VERSION"
  printf 'slug = "demo"\ncurrent_version = "0.1.0"\n' >"$D/skill.toml"
  printf -- '---\nname: schematize-docs\nmetadata:\n  version: 0.1.0\n---\n**Versão:** skill `schematize-docs` v0.1.0.\n' >"$D/SKILL.md"
  printf '# Changelog\n\n## [%s] — 2026-10-14\nx\n\n## [0.1.0] — 2026-10-13\ny\n' "$2" >"$D/CHANGELOG.md"
}

echo "== verde"
skill bump-ok 0.2.0;            esperar 0 "0.1.0 -> 0.2.0" "$D" 0.2.0
NOME="bump-ok-4-lugares"; v1="$(cat "$D/VERSION")"; v2="$(sed -n 's/^current_version = "\(.*\)"/\1/p' "$D/skill.toml")"
v3="$(sed -n 's/^  version: //p' "$D/SKILL.md")"; v4="$(sed -n 's/.* v\([0-9.]*\)\.$/\1/p' "$D/SKILL.md")"
if [ "$v1$v2$v3$v4" = "0.2.00.2.00.2.00.2.0" ] && [ -d "$D/versions/v0.2.0" ]; then echo "  ok $NOME"; ok=$((ok+1)); else echo "  x $NOME: $v1 $v2 $v3 $v4"; fail=$((fail+1)); fi
skill dry-run 0.2.0;            esperar 0 "dry-run" "$D" 0.2.0 --dry-run
NOME="dry-run-nao-grava"; if [ "$(cat "$D/VERSION")" = "0.1.0" ] && [ ! -d "$D/versions" ]; then echo "  ok $NOME"; ok=$((ok+1)); else echo "  x $NOME"; fail=$((fail+1)); fi

echo "== vermelho"
skill semver-invalido 0.2.0;    esperar 1 "versão inválida" "$D" v0.2
skill versao-igual 0.1.0;       esperar 1 "não é maior" "$D" 0.1.0
skill versao-menor 0.0.9;       esperar 1 "não é maior" "$D" 0.0.9
skill changelog-sem-entrada 0.2.0; esperar 1 "1ª entrada do CHANGELOG.md" "$D" 0.3.0
skill sem-linha-versao 0.2.0;   sed -i '/^\*\*Versão/d' "$D/SKILL.md"; esperar 1 "linha" "$D" 0.2.0
skill recusa-nao-altera 0.2.0;  bash "$B" "$D" 0.1.5 >/dev/null 2>&1; NOME="recusa-nao-altera"
if [ "$(cat "$D/VERSION")" = "0.1.0" ] && grep -q 'current_version = "0.1.0"' "$D/skill.toml"; then echo "  ok $NOME"; ok=$((ok+1)); else echo "  x $NOME: alterou antes de recusar"; fail=$((fail+1)); fi
NOME="sem-argumentos";          esperar 2 "uso:"
NOME="dir-inexistente";         esperar 2 "não é diretório" "$TMP/nao-existe" 0.2.0

echo
echo "resultado: $ok ok, $fail falhas"
[ "$fail" -eq 0 ]
