---
name: editor-video-pt
description: Padrão profissional de edição de vídeo em português (pt-BR). Use SEMPRE que o usuário enviar gravações brutas ou pedir edição para Instagram/Reels, TikTok, YouTube, Shorts ou anúncios — "edita esse vídeo", "corta as pausas", "tira os erros", "coloca legenda", "faz versão vertical", "melhora o áudio", "zoom", "exporta". Orquestra video-editing-skill (cortes), ffmpeg-skill (formatos, legendas, checagem) e HyperFrames (animações, só quando pedido). Tudo local, sem APIs pagas.
---

# Editor de vídeo pt-BR — padrão da casa

Este arquivo é o **padrão**. As skills `video-editing-skill` (cortes, áudio, SRT) e
`ffmpeg-skill` (reframe, legendas animadas, export, checagem) são as ferramentas. Leia o
SKILL.md delas quando precisar de detalhes de flags.

Fale com o usuário em **português**. Explique decisões em linguagem simples, sem jargão.

## 0. Ambiente (carregar em todo comando)

```bash
source ~/.claude/skills/editor-video-pt/scripts/ambiente.sh
```

Define `$PY` (Python com faster-whisper), `$VES` (video-editing-skill), `$FFS`
(ffmpeg-skill), `$EVP` (estes scripts), `$FONTS`, e o modelo Whisper `medium` local em
português, com `HF_HUB_OFFLINE=1`. Se `$PY` ou o modelo não existirem (container novo),
avise o usuário e reinstale seguindo `referencias/instalacao.md` — **peça aprovação antes**.

## Regras invioláveis

1. **Originais nunca são tocados.** Sempre `novo_projeto.sh` primeiro: copia os brutos para
   `originais/` como somente leitura e grava SHA256. Nenhum comando escreve em `originais/`.
2. **Privacidade:** nada sai da máquina. Transcrição = faster-whisper local. Não usar
   Groq/OpenAI/ElevenLabs/WoopSocial/fal.ai nem nenhum conector externo sem o usuário pedir
   explicitamente e entender o custo e o envio de dados. Não postar nada.
3. **Aprovação antes de renderizar.** Mostre o plano de cortes (resumo, retakes, cortes
   editoriais, duração final) e espere o "ok". Exceção: o usuário disse "pode renderizar direto".
4. **Nunca cortar dentro de palavra**; o `edit_video.py` já ajusta as bordas pelo som.
5. **Legendas por último** na cadeia (depois de zoom, overlays e reframe).
6. **"é" sozinho não é vício** (é o verbo). "tipo", "né", "então", "aí" só entram em
   `extra_fillers` se o usuário aprovar.
7. **Verificar antes de mostrar:** checagem técnica + leitura de volta + frames (seção 6).
   Você não ouve o áudio: reporte números (LUFS, true peak), não "está ótimo".
8. Máximo 3 ciclos de autocorreção; depois disso, mostre o problema ao usuário.

## Estrutura de pastas

```
/home/user/videos/<projeto>/
├── originais/      brutos somente leitura + SHA256SUMS
├── trabalho/       transcript, edit-*.json, planos, intermediários, verificacao/
├── previa/         versões leves (720p / 540x960) + antes-depois.jpg
├── saida/          SOMENTE entregáveis: <projeto>_<destino>_<aspecto>.mp4 + .srt (+ capitulos.txt)
└── projeto.md      memória: decisões de cada sessão (anexar ao final)
```

O app do usuário só abre arquivos dentro de `/home/user`. Ao terminar, envie as prévias e
os finais com `SendUserFile`.

## Fluxo

### 1. Inventário
```bash
$EVP/novo_projeto.sh <projeto> <brutos...>
cd /home/user/videos/<projeto>
python3 $FFS/probe.py originais/<arquivo> --json-brief
```
Leia `projeto.md` se existir e resuma a última sessão em uma frase.

### 2. Transcrição (local, cache)
```bash
$PY $VES/transcribe.py originais/<arquivo> --engine local --model medium --language pt \
    --terms "Nomes, Marcas, Termos" --out trabalho
```
Não retranscreva se `trabalho/transcript.json` já existe para o mesmo arquivo. Velocidade
de referência: ~0,7× a duração do vídeo (4 vCPU, sem GPU). Vários brutos: uma pasta
`trabalho/<nome>/` por arquivo.

### 3. Perguntas (só o que não dá para ver)
Destino(s) e formato · duração alvo · ritmo (youtube / tight / podcast) · o que é intocável ·
nomes próprios · muletas que pode cortar · CTA final · se quer zoom, textos, animações.
Se o usuário já disse, não pergunte de novo.

### 4. Plano de cortes
Leia `trabalho/transcript.txt` inteiro. Escreva `trabalho/edit-<destino>.json`
(formato no topo de `$VES/edit_video.py`). **Caminho do vídeo absoluto.** Sempre inclua
`"language": "pt"`. Use:
- `cut` para retakes (tentativa errada → manter a **última boa**), tangentes, "tá gravando?".
  Duas frases completas que começam igual nunca são cortadas sozinhas: decida e justifique.
- `replace` para corrigir palavras mal reconhecidas na legenda.
- `keep` para proteger trechos.
- `chapters` (YouTube, ≥ 3 capítulos de ≥ 10 s, primeiro em 0:00).
```bash
$PY $VES/edit_video.py trabalho/edit-<destino>.json --transcript trabalho/transcript.json --out trabalho/<destino> --plan
```
Apresente ao usuário: duração antes → depois, % cortado, ritmo (palavras/min; alerta > 190),
tabela de remoções, retakes duvidosos. **Espere aprovação.**

Vários takes em arquivos separados (melhor tomada): transcreva todos, monte uma tabela
"trecho do roteiro → take escolhido → motivo", e una os trechos escolhidos com
`$FFS/cut.py` + `$FFS/join.py` antes do passo 5; ou edite cada take e una no fim.

### 5. Render base (16:9 ou formato da fonte)
```bash
$PY $VES/edit_video.py trabalho/edit-<destino>.json --transcript trabalho/transcript.json --out trabalho/<destino>
```
Gera: cortes com fades curtos, punch-ins de 1,10× nos jump cuts (zoom), limpeza de áudio
(rumble, denoise medido, compressão, limiter) e −14 LUFS, `captions.srt`, `chapters.txt`,
`cuts.jpg`, `manifest.json`. Leia os avisos do manifest.

### 6. Versões por plataforma
Ver tabela em `referencias/formatos.md`. Receita vertical (Reels/TikTok/Shorts):
```bash
python3 $EVP/srt_chunk.py trabalho/<destino>/captions.srt trabalho/legendas-social.srt --words 3
python3 $FFS/fit.py trabalho/<destino>/edited.mp4 --aspect 9:16 --fit crop --width 1080 --height 1920 \
    -o trabalho/vertical-sem-legenda.mp4 --overwrite
python3 $FFS/caption.py trabalho/vertical-sem-legenda.mp4 --srt trabalho/legendas-social.srt \
    --fonts-dir $FONTS --font "Poppins ExtraBold" --platform tiktok --size 16 --outline 3 \
    --animate pop --karaoke --karaoke-style word --highlight-color "#FFD23F" \
    --position bottom --max-lines 2 -o saida/<projeto>_reels-tiktok_9x16.mp4 --overwrite
```
- Se o rosto não está centralizado, ajuste `--crop-x` (ou use `--fit blur` para tela/slides).
- YouTube 16:9: **não** queimar legenda; embutir faixa liga/desliga + entregar `.srt`:
  `python3 $FFS/caption.py saida/X.mp4 --mode mux --srt saida/X.srt:por -o ...`
- Anúncio: hook nos 3 primeiros segundos, legenda queimada, 4:5 (feed) e 9:16 (stories),
  duração alvo ≤ 30 s, CTA nos 3 s finais. Use `$FFS/graphics.py` para texto de hook/CTA.
- Zooms extras de ênfase (fora dos punch-ins automáticos): `$FFS/speedramp.py`/`crop.py` ou
  filtro `zoompan`/`crop` com easing; aplicar **antes** da legenda.
- Animações/motion graphics: ver `referencias/animacoes.md` (HyperFrames, sob demanda).

### 7. Verificação (antes de mostrar)
```bash
python3 $FFS/check.py saida/<arquivo> --platform <reels|tiktok|youtube|shorts>   # 0 failed
$PY $VES/transcribe.py saida/<16x9>.mp4 --engine local --model medium --language pt --out trabalho/verificacao
```
- Leia a transcrição do final: frases completas? sobrou vício/retake? palavra cortada?
- Gere uma folha de frames (`ffmpeg ... select=...,tile=4x1`) e **olhe** com Read: legenda
  legível no celular, fora do rosto e da UI, crop enquadrando a pessoa, cortes limpos.
- Áudio: −14 LUFS ±1, true peak ≤ −1 dBTP (o check.py mede).

### 8. Entrega
- `previa/`: versões leves + `antes-depois.jpg`; envie com `SendUserFile` (status normal).
- `saida/`: só os finais. Nomes: `<projeto>_<destino>_<aspecto>.mp4` e `.srt` com o mesmo nome.
- Relatório curto: duração antes→depois, o que foi cortado, números de áudio, avisos.
- Anexe uma seção em `projeto.md` (data, estratégia, decisões, pendências).

## Estilo visual neutro (padrão aprovado)

- Fonte: Poppins ExtraBold (OFL, já incluída em `$FONTS`).
- Legenda social: branca, contorno preto 3, palavra ativa em amarelo `#FFD23F`, animação
  `pop`, 2–3 palavras por bloco, máx. 2 linhas, posição `bottom` com zona segura TikTok.
- Textos/títulos: branco sobre faixa preta 70 %, cantos discretos, sem emojis por padrão.
- Grade de cor: nenhuma por padrão; só corretiva (exposição/balanço de branco) se pedido,
  via `$FFS/color.py`, conferindo tom de pele em frame.
- Se o usuário enviar identidade visual depois, registre em `referencias/marca.md` e use.
