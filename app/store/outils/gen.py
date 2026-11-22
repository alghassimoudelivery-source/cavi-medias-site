#!/usr/bin/env python3
"""Génère les pages HTML des visuels de fiche store (3 propositions)."""
import os

D = os.path.dirname(os.path.abspath(__file__))

SHOTS = [
    ("accueil-0.png", "CaviTV, Cavi FM et Siam Info", "dans une seule application"),
    ("cavitv-0.png", "CaviTV en direct", "la chaîne du groupe, 24 h/24"),
    ("cavifm-0.png", "Cavi FM partout", "même écran éteint"),
    ("plus-0.png", "La rédaction", "à portée de main"),
]
COLORS2 = ["#2f6fe0", "#e8262b", "#5b55c9", "#161c30"]

HEAD = """<!doctype html><html lang="fr"><head><meta charset="utf-8"><style>
@font-face{font-family:Inter;font-weight:400;src:url(Inter-400.ttf)}
@font-face{font-family:Inter;font-weight:600;src:url(Inter-600.ttf)}
@font-face{font-family:Inter;font-weight:700;src:url(Inter-700.ttf)}
@font-face{font-family:Inter;font-weight:800;src:url(Inter-800.ttf)}
@font-face{font-family:Bebas;src:url(Bebas.ttf)}
*{box-sizing:border-box;margin:0}
body{font-family:Inter,sans-serif;color:#fff;overflow:hidden}
.phone{position:absolute;background:#05070d;border-radius:46px;padding:11px;box-shadow:0 30px 60px rgba(0,0,0,.45)}
.phone img{display:block;width:100%;border-radius:36px}
</style></head><body>"""


def phone(src, left, top, width, rot=0, extra=""):
    return (f'<div class="phone" style="left:{left}px;top:{top}px;width:{width}px;'
            f'transform:rotate({rot}deg);{extra}"><img src="{src}"></div>')


def shot(p, i):
    src, h1, h2 = SHOTS[i]
    if p == 1:  # Nuit : fond bleu nuit, formes rondes, titre en haut
        body = f"""<div style="position:relative;width:430px;height:932px;background:#0c1020;overflow:hidden">
<div style="position:absolute;right:-120px;top:-90px;width:330px;height:330px;border-radius:50%;background:#2f6fe0;opacity:.9"></div>
<div style="position:absolute;left:-90px;bottom:120px;width:240px;height:240px;border-radius:50%;background:#5b55c9;opacity:.55"></div>
<div style="position:absolute;left:32px;top:62px;right:32px">
<div style="font-size:15px;font-weight:600;letter-spacing:.14em;color:#9cbcff;text-transform:uppercase;margin-bottom:12px">Cavi-Medias</div>
<div style="font-size:38px;font-weight:800;line-height:1.08;letter-spacing:-.02em">{h1}</div>
<div style="font-size:21px;font-weight:600;color:#a3abc4;margin-top:10px">{h2}</div></div>
{phone(src, 63, 300, 304)}</div>"""
    elif p == 2:  # Couleurs : une couleur de marque par écran, téléphone incliné
        c = COLORS2[i]
        body = f"""<div style="position:relative;width:430px;height:932px;background:{c};overflow:hidden">
<div style="position:absolute;left:30px;top:58px;right:30px;text-align:center">
<div style="font-size:40px;font-weight:800;line-height:1.08;letter-spacing:-.02em">{h1}</div>
<div style="font-size:21px;font-weight:600;opacity:.88;margin-top:10px">{h2}</div></div>
{phone(src, 52, 268, 326, -5)}</div>"""
    else:  # Affiche : noir cinéma, titres Bebas, barre rouge, téléphone décalé
        body = f"""<div style="position:relative;width:430px;height:932px;background:#0b0b0f;overflow:hidden">
<div style="position:absolute;left:0;right:0;bottom:0;height:300px;background:#e8262b"></div>
<div style="position:absolute;left:30px;top:56px;right:24px">
<div style="width:46px;height:5px;background:#e8262b;margin-bottom:16px"></div>
<div style="font-family:Bebas;font-size:66px;line-height:.9">{h1}</div>
<div style="font-size:20px;font-weight:600;color:#c9cad3;margin-top:12px">{h2}</div></div>
{phone(src, 70, 330, 290)}</div>"""
    return HEAD + body + "</body></html>"


def feature(p):
    if p == 1:
        body = f"""<div style="position:relative;width:1024px;height:500px;background:#0c1020;overflow:hidden">
<div style="position:absolute;right:-60px;top:-140px;width:520px;height:520px;border-radius:50%;background:#2f6fe0"></div>
<div style="position:absolute;right:300px;bottom:-160px;width:300px;height:300px;border-radius:50%;background:#5b55c9;opacity:.7"></div>
<div style="position:absolute;left:64px;top:96px;width:520px">
<img src="cavi-medias-logo-horizontal-blanc.svg" style="height:52px;margin-bottom:34px">
<div style="font-size:46px;font-weight:800;line-height:1.08;letter-spacing:-.02em">La télé, la radio et l'info du groupe</div>
<div style="font-size:22px;color:#a3abc4;margin-top:16px">CaviTV · Cavi FM · Siam Info</div></div>
{phone('accueil-0.png', 700, 40, 240, 0, 'border-radius:34px;padding:8px')}</div>"""
    elif p == 2:
        body = f"""<div style="position:relative;width:1024px;height:500px;background:#2f6fe0;overflow:hidden">
<div style="position:absolute;right:0;top:0;bottom:0;width:380px;background:#e8262b"></div>
<div style="position:absolute;left:64px;top:110px;width:520px">
<img src="cavi-medias-logo-horizontal-blanc.svg" style="height:50px;margin-bottom:30px">
<div style="font-size:46px;font-weight:800;line-height:1.08;letter-spacing:-.02em">Toute l'actualité du groupe Cavi-Medias</div></div>
{phone('cavitv-0.png', 600, 70, 210, -6, 'border-radius:30px;padding:7px')}
{phone('cavifm-0.png', 790, 40, 210, 5, 'border-radius:30px;padding:7px')}</div>"""
    else:
        body = f"""<div style="position:relative;width:1024px;height:500px;background:#0b0b0f;overflow:hidden">
<div style="position:absolute;left:0;top:0;bottom:0;width:12px;background:#e8262b"></div>
<div style="position:absolute;right:0;bottom:0;width:440px;height:200px;background:#e8262b"></div>
<div style="position:absolute;left:64px;top:84px;width:560px">
<img src="cavi-medias-logo-horizontal-blanc.svg" style="height:46px;margin-bottom:26px">
<div style="font-family:Bebas;font-size:96px;line-height:.88">La télé, la radio<br>et l'info</div>
<div style="font-size:20px;color:#c9cad3;margin-top:14px">CaviTV · Cavi FM · Siam Info, en direct</div></div>
{phone('cavifm-0.png', 720, 36, 230, 0, 'border-radius:32px;padding:8px')}</div>"""
    return HEAD + body + "</body></html>"


for p in (1, 2, 3):
    open(os.path.join(D, f"p{p}-feature.html"), "w").write(feature(p))
    for i in range(4):
        open(os.path.join(D, f"p{p}-s{i+1}.html"), "w").write(shot(p, i))
