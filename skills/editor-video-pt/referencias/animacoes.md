# Animações e motion graphics

Ordem de preferência (mais simples primeiro):

1. **ffmpeg-skill** — `graphics.py` (títulos, lower thirds, hook, CTA), `overlay.py` (logo,
   imagens), `caption.py` (legendas animadas). Sem instalar nada. Cobre 80 % dos pedidos.
2. **PIL + sequência PNG + ffmpeg** — cartões simples (contador, texto digitando, barra).
   Easing sempre cúbico (`1-(1-t)**3`), nunca linear.
3. **HyperFrames** (Apache 2.0, HeyGen) — motion graphics em HTML/CSS/GSAP com render
   determinístico, overlay transparente WebM. **Instalar só no primeiro uso, com aprovação**,
   dentro da pasta da animação, com telemetria desligada:
   ```bash
   export HYPERFRAMES_NO_TELEMETRY=1 DO_NOT_TRACK=1
   mkdir -p trabalho/animacoes/slot_1 && cd trabalho/animacoes/slot_1
   npx --yes hyperframes init . --example blank --non-interactive --skip-skills
   npx --yes hyperframes lint . && npx --yes hyperframes render . --format webm -o render.webm
   ```
   O render usa Chromium headless (já existe em `/opt/pw-browsers/chromium`). Não usar
   comandos `tts`, `transcribe` ou Studio Pro do HyperFrames sem o usuário pedir.

**Remotion não é usado** (licença paga para empresas com mais de 3 funcionários; redundante).

Regras (aprendidas do video-use):
- Overlay entra com `setpts=PTS-STARTPTS+T/TB` para começar no frame 0 da animação.
- A animação "pousa" no momento da palavra-chave falada: inicie `duração_da_entrada` antes.
- Segure o último frame ≥ 1 s. Nunca revele dois elementos novos ao mesmo tempo.
- Confirme que a fonte carregou (fonte web que falha cai em fallback sem erro).
- Legendas sempre por cima e por último.
- Várias animações: um subagente por animação, em paralelo, cada um com caminho de saída único.
