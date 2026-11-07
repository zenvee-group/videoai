# Reinstalação (container novo)

O kit está no repositório privado `zenvee-group/videoai`. Numa sessão sem as ferramentas:

```bash
bash /home/user/videoai/setup.sh     # ou o caminho onde o repositório foi clonado
```

Instala: venv em /root/video-tools (faster-whisper 1.2.1, Pillow, av<17), modelo Whisper
medium (~1,5 GB, Hugging Face), copia as skills para ~/.claude/skills e o CLAUDE.md.
Rede necessária: huggingface.co, us.aws.cdn.hf.co, cas-bridge.xethub.hf.co,
cas-server.xethub.hf.co; PyPI liberado. Pedir aprovação antes de rodar.
