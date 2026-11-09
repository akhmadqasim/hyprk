#!/usr/bin/env python3
"""Draw the white status icons shown top-right on the lock screen (wifi, wifi off, battery levels, charging, none).
Original artwork, drawn with PIL at 8x and downsampled. Output: assets/status/*.png (committed)."""
import pathlib
from PIL import Image, ImageDraw

OUT = pathlib.Path(__file__).resolve().parent / 'status'
OUT.mkdir(exist_ok=True)
S, K = 36, 8            # icon box and supersampling
W = (255, 255, 255, 235)


def canvas():
    im = Image.new('RGBA', (S * K, S * K), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def save(im, name):
    im.resize((S, S), Image.LANCZOS).save(OUT / f'{name}.png')


def wifi(name, off=False):
    im, d = canvas()
    cx, cy = S * K / 2, S * K * 0.78
    for i in range(3):
        r = S * K * (0.16 + i * 0.17)
        d.arc((cx - r, cy - r, cx + r, cy + r), 225, 315, fill=W, width=int(S * K * 0.075))
    d.ellipse((cx - S * K * 0.055, cy - S * K * 0.055, cx + S * K * 0.055, cy + S * K * 0.055), fill=W)
    if off:
        d.line((S * K * .2, S * K * .2, S * K * .8, S * K * .8), fill=W, width=int(S * K * 0.07))
    save(im, name)


def battery(name, level=None, charging=False):
    im, d = canvas()
    x0, y0, x1, y1 = S * K * .08, S * K * .32, S * K * .84, S * K * .68
    d.rounded_rectangle((x0, y0, x1, y1), radius=S * K * .09, outline=(255, 255, 255, 150), width=int(S * K * .045))
    d.rounded_rectangle((x1 + S * K * .025, S * K * .43, x1 + S * K * .075, S * K * .57), radius=S * K * .02, fill=(255, 255, 255, 150))
    if level:
        pad = S * K * .07
        right = x0 + pad + (x1 - x0 - 2 * pad) * level / 100
        col = (255, 69, 58, 240) if level <= 15 else W
        d.rounded_rectangle((x0 + pad, y0 + pad, right, y1 - pad), radius=S * K * .04, fill=col)
    if charging:
        bolt = [(.50, .24), (.38, .52), (.47, .52), (.42, .78), (.60, .45), (.50, .45)]
        d.polygon([(S * K * x, S * K * y) for x, y in bolt], fill=(30, 30, 30, 255), outline=W)
    save(im, name)


wifi('wifi-3'); wifi('wifi-off', off=True)
for lv in (100, 75, 50, 25, 10):
    battery(f'battery-{lv}', lv)
battery('battery-charging', 80, charging=True)
Image.new('RGBA', (S, S), (0, 0, 0, 0)).save(OUT / 'none.png')
