#!/usr/bin/env python3
"""Divide um SRT em blocos curtos (padrão: até 3 palavras) para legendas de redes sociais.
Tempo de cada bloco proporcional ao número de caracteres dentro da legenda original.
Uso: python3 srt_chunk.py entrada.srt saida.srt [--words 3] [--upper] [--min 0.35]
"""
import argparse, re

def ts(s):
    h, m, rest = s.split(":"); sec, ms = rest.split(",")
    return int(h) * 3600 + int(m) * 60 + int(sec) + int(ms) / 1000

def fmt(t):
    ms = int(round(t * 1000)); h, ms = divmod(ms, 3600000); m, ms = divmod(ms, 60000); s, ms = divmod(ms, 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"

def parse(path):
    blocks = re.split(r"\n\s*\n", open(path, encoding="utf-8").read().strip())
    for b in blocks:
        lines = b.strip().splitlines()
        t = next(i for i, l in enumerate(lines) if "-->" in l)
        a, z = [x.strip() for x in lines[t].split("-->")]
        yield ts(a), ts(z), " ".join(lines[t + 1:])

def chunk(words, n):
    out, cur = [], []
    for w in words:
        cur.append(w)
        if len(cur) >= n or re.search(r"[.,!?;:]$", w):
            out.append(cur); cur = []
    if cur:
        if out and len(cur) == 1 and len(out[-1]) < n + 1: out[-1] += cur
        else: out.append(cur)
    return out

ap = argparse.ArgumentParser()
ap.add_argument("inp"); ap.add_argument("out")
ap.add_argument("--words", type=int, default=3); ap.add_argument("--upper", action="store_true")
ap.add_argument("--min", type=float, default=0.35)
a = ap.parse_args()
cues = []
for s, e, text in parse(a.inp):
    groups = chunk(text.split(), a.words)
    total = sum(len(" ".join(g)) for g in groups) or 1
    t = s
    for g in groups:
        d = (e - s) * len(" ".join(g)) / total
        txt = " ".join(g).rstrip(",;")
        cues.append([t, t + d, txt.upper() if a.upper else txt]); t += d
# junta blocos curtos demais ao anterior (evita "piscar")
merged = []
for c in cues:
    if merged and c[1] - c[0] < a.min and abs(merged[-1][1] - c[0]) < 0.05:
        merged[-1][1] = c[1]; merged[-1][2] += " " + c[2]
    else: merged.append(c)
if len(merged) > 1 and merged[0][1] - merged[0][0] < a.min:
    merged[1][0] = merged[0][0]; merged[1][2] = merged[0][2] + " " + merged[1][2]; merged.pop(0)
with open(a.out, "w", encoding="utf-8") as f:
    for i, (s, e, t) in enumerate(merged, 1):
        f.write(f"{i}\n{fmt(s)} --> {fmt(e)}\n{t}\n\n")
print(f"{len(merged)} blocos -> {a.out}")
