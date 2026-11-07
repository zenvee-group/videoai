#!/usr/bin/env bash
# Cria a estrutura de um projeto e copia os brutos como SOMENTE LEITURA.
# Uso: novo_projeto.sh <nome-do-projeto> <arquivo1> [arquivo2 ...]
set -euo pipefail
NOME="$1"; shift
BASE="/home/user/videos/$NOME"
mkdir -p "$BASE"/{originais,trabalho/verificacao,previa,saida}
chmod u+w "$BASE/originais/SHA256SUMS" 2>/dev/null || true
for f in "$@"; do
  dest="$BASE/originais/$(basename "$f")"
  [ -e "$dest" ] && { echo "já existe, mantido: $dest"; continue; }
  cp -p "$f" "$dest"; chmod a-w "$dest"
  sha256sum "$dest" >> "$BASE/originais/SHA256SUMS"
done
chmod a-w "$BASE/originais/SHA256SUMS" 2>/dev/null || true
[ -f "$BASE/projeto.md" ] || printf '# %s\n\n' "$NOME" > "$BASE/projeto.md"
echo "Projeto pronto em $BASE"
