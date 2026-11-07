#!/usr/bin/env bash
# Instala o kit de edição de vídeo numa sessão nova do Claude Code (idempotente).
# Uso: bash setup.sh          (VT=/root/video-tools por padrão; SKIP_MODEL=1 pula o modelo)
set -euo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VT="${VT:-/root/video-tools}"
echo "[kit-video] kit em $KIT, ferramentas em $VT"

command -v ffmpeg >/dev/null || { apt-get update -qq && apt-get install -y -qq ffmpeg; }
command -v uv >/dev/null || pip install -q uv

mkdir -p "$VT"
[ -x "$VT/.venv/bin/python" ] || uv venv -q "$VT/.venv" --python 3.12
# av 19 remove um argumento usado pelo faster-whisper 1.2.1 -> fixar av < 17
uv pip install -q --python "$VT/.venv/bin/python" "faster-whisper==1.2.1" "pillow" "numpy" "av>=15,<17"

if [ "${SKIP_MODEL:-0}" != "1" ] && ! ls "$VT"/models/models--Systran--faster-whisper-medium/snapshots/*/model.bin >/dev/null 2>&1; then
  echo "[kit-video] baixando modelo Whisper medium (~1,5 GB)..."
  HF_HUB_DISABLE_XET=1 "$VT/.venv/bin/python" -c "from faster_whisper import WhisperModel; WhisperModel('medium', device='cpu', compute_type='int8', download_root='$VT/models')"
fi

mkdir -p "$HOME/.claude/skills"
for s in editor-video-pt video-editing-skill ffmpeg-skill; do
  rm -rf "$HOME/.claude/skills/$s"
  cp -r "$KIT/skills/$s" "$HOME/.claude/skills/$s"
done
grep -q "editor-video-pt" "$HOME/.claude/CLAUDE.md" 2>/dev/null || cat "$KIT/claude/CLAUDE.md" >> "$HOME/.claude/CLAUDE.md"
mkdir -p /home/user/videos
echo "[kit-video] pronto."
