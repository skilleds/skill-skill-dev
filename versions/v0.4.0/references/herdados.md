<!-- cross-skill: precedencia.md, orquestracao.md -> schematize-engineering -->
# Blocos herdados

> Parte da `schematize-skill-dev`. Texto normativo que várias skills repetem vem de UMA fonte; a
> cópia nas skills é gerada, nunca escrita.

## 1. Por que existe

A regra de orquestração e o texto de precedência eram copiados à mão em dezenas de skills; cada
mudança na base exigia editar dezenas de arquivos e as cópias divergiam. Hoje a fonte vive na base
(`schematize-engineering`, pasta `assets/herdados/`, um arquivo por assunto) e `tools/sync-herdados.mjs`
do catálogo reescreve as cópias.

## 2. Fonte: variantes

Cada arquivo-fonte (`precedencia.md`, `orquestracao.md`, ...) tem variantes delimitadas por um
comentário `variante:NOME` aberto e fechado. Exemplos de variante: `curto` (orquestração em uma linha de
lista), `dominio`, `backend`, `foraRol`, `mobile` (precedência). O texto da variante pode ter
parâmetros `{{chave}}`.

## 3. Consumidor: o marcador

No `SKILL.md` e no `assets/CLAUDE.md` da skill, o corpo herdado fica entre um marcador de abertura
`herdado:<base>/<id>:<variante>` (num comentário HTML, com pares `chave="valor"` opcionais) e o
marcador de fechamento (comentário HTML com barra e a palavra herdado). Duas regras do marcador:

- **Mesma linha do item de lista**, para não quebrar a numeração (o piso de orquestração é um item).
- **Parâmetro faltando, sobrando ou `{{x}}` sem valor é erro** do sync: pega typo antes de virar texto
  errado publicado. Valor numa linha, sem aspas internas.

Variante de precedência para skill de domínio: parâmetros `intro` (uma frase dizendo qual recorte a
skill é) e `cmd` (o prefixo dos comandos). Para skill de linguagem de backend: `slug` e `linguagem`.
Leia a variante na fonte antes de escolher.

**Nunca escreva o marcador literal em prosa ou em exemplo dentro de uma skill:** o sync o trata como
bloco real (e o gate reprova abertura sem fechamento). Para citar a sintaxe, use placeholders com `<>`
(como acima).

## 4. Arquivos herdados inteiros

O manifesto `tools/herdados-arquivos.json` lista `fonte`, `destino` e, por skill, os parâmetros.
A skill listada recebe o arquivo (com `{{chave}}` substituído) e um cabeçalho "herdado de
schematize-engineering — não edite aqui". Para entrar na lista, é preciso mexer no manifesto do
catálogo (dono do catálogo); a skill nova só recebe o que já está lá.

## 5. Rito

1. Ponha os marcadores na skill (vazios servem; o sync preenche).
2. Rode `node tools/sync-herdados.mjs --write` **numa cópia do catálogo** quando houver trabalho
   de outras skills em andamento: o `--write` pode tocar arquivos alheios; use `--root <cópia>` e
   traga de volta só os arquivos da sua skill.
3. `node tools/sync-herdados.mjs --check` não escreve e sai 1 se algo divergir; é o que o CI cobra.
4. Commite só os arquivos da sua skill.

## 6. Nunca

- Editar o texto entre os marcadores: o próximo sync desfaz, e o `--check` reprova antes.
- Divergir do piso herdado "só nesta skill": divergência de piso é defeito da skill, não variante.
  Quer mudar o piso? Muda na fonte, na base, e roda o sync em todos.
- Copiar o texto herdado para uma skill nova "para não depender do sync".

## 7. O que o gate local confere

`check-skill.sh` exige, fora da base, o bloco de orquestração no `SKILL.md` e no `assets/CLAUDE.md`
e o de precedência no `SKILL.md`, e reprova abertura sem fechamento. Que o CONTEÚDO esteja igual à
fonte é do `--check` do catálogo.
