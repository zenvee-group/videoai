# Formatos de entrega (padrão)

Fonte técnica: `~/.claude/skills/ffmpeg-skill/scripts/_platforms.py` (o `check.py` usa esses
valores). Todos: H.264 + AAC 48 kHz, yuv420p, BT.709, −14 LUFS (±2), true peak ≤ −1 dBTP.

| Destino | Resolução | Aspecto | FPS | Duração máx. (check) | Legenda | Zona segura (topo/base/dir.) |
|---|---|---|---|---|---|---|
| Instagram Reels | 1080×1920 | 9:16 | 30 | 90 s | queimada, animada | 8 % / 20 % / 12 % |
| Instagram Feed | 1080×1350 | 4:5 | 30 | — | queimada | — |
| TikTok | 1080×1920 | 9:16 | 30 | 600 s | queimada, animada | 10 % / 22 % / 14 % |
| YouTube Shorts | 1080×1920 | 9:16 | 30 | 180 s | queimada, animada | 6 % / 18 % / 12 % |
| YouTube | 1920×1080 (ou fonte) | 16:9 | fonte | 12 h | **faixa embutida + .srt** (não queimar) + capítulos | — |
| Anúncio Stories/Reels | 1080×1920 | 9:16 | 30 | ideal ≤ 30 s | queimada | usar zona TikTok (mais restritiva) |
| Anúncio Feed | 1080×1350 | 4:5 | 30 | ideal ≤ 30 s | queimada | — |

Regras práticas:
- Um único corte aprovado gera todas as versões (cortes, áudio e tempos de legenda iguais).
- Para Reels + TikTok, uma única versão 9:16 com `--platform tiktok` serve aos dois.
- 4:5: `fit.py --aspect 4:5 --fit crop --width 1080 --height 1350`.
- Reels > 90 s: avisar o usuário (o Instagram aceita, mas o alcance como Reel cai).
- Anúncio: 0–3 s hook visual + texto; legenda queimada (a maioria assiste sem som);
  CTA em texto nos 3 s finais; sem música com direitos não liberados.
