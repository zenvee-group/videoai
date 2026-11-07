# Kit de edição de vídeo — Claude Code (pt-BR)

Transforma o Claude Code num editor de vídeo para Instagram, TikTok, YouTube e anúncios:
melhores tomadas, cortes de pausas/vícios/retakes, áudio a −14 LUFS, legendas sincronizadas,
zoom, textos e exportação por plataforma. **Tudo local, custo zero, sem envio de mídia.**

## Uso
1. Numa sessão nova: `bash setup.sh` (ou automático pelo script do ambiente).
2. Envie a gravação bruta e peça em português: *"edita para Reels e YouTube, ritmo rápido"*.
3. O Claude mostra o plano de cortes → você aprova → recebe prévia e os MP4 em
   `/home/user/videos/<projeto>/saida/`.

## Conteúdo
| Pasta | O quê | Licença |
|---|---|---|
| `skills/editor-video-pt` | Padrão da casa: fluxo, regras, formatos, estilo, animações | própria |
| `skills/video-editing-skill` | Cortes, áudio, SRT ([social-media-skills](https://github.com/social-media-skills/video-editing-skill)) com patch pt-BR | MIT |
| `skills/ffmpeg-skill` | 42 ferramentas ffmpeg, legendas animadas, checagem ([kajisho5](https://github.com/kajisho5/ffmpeg-skill)) | MIT |
| `patches/` | Diff do patch pt-BR aplicado ao video-editing-skill | — |
| `claude/CLAUDE.md` | Preferências globais (idioma, privacidade, aprovações) | — |
| `setup.sh` | Instalador idempotente | — |

Fonte Poppins: SIL OFL (em `skills/video-editing-skill/fonts`).
