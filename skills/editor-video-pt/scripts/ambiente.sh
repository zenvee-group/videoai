# Carregue com: source ~/.claude/skills/editor-video-pt/scripts/ambiente.sh
export VT=/root/video-tools
export PY=$VT/.venv/bin/python                     # Python com faster-whisper + Pillow
export WHISPER_MODELS_DIR=$VT/models               # modelo medium já baixado (1,5 GB)
export WHISPER_MODEL=medium WHISPER_LANGUAGE=pt
export HF_HUB_OFFLINE=1                            # nunca baixar nada durante a edição
export HYPERFRAMES_NO_TELEMETRY=1 DO_NOT_TRACK=1   # caso use HyperFrames
export VES=$HOME/.claude/skills/video-editing-skill/scripts
export FFS=$HOME/.claude/skills/ffmpeg-skill/scripts
export EVP=$HOME/.claude/skills/editor-video-pt/scripts
export FONTS=$HOME/.claude/skills/video-editing-skill/fonts
